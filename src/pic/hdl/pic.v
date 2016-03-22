`include "pic_regmap.vh"
//###########################################################################
//# IRQC: Simple nested interrupt controller
//# 
//############################################################################
module pic(/*AUTOARG*/
   // Outputs
   ic_flush, ic_iret_reg, ic_imask_reg, ic_ilat_reg, ic_ipend_reg,
   ic_irq, ic_irq_addr,
   // Inputs
   clk, nreset, reg_write, reg_addr, reg_wdata, ext_irq,
   sq_pc_next_ra, de_rti_e1, sq_global_irq_en, sq_ic_wait
   );

   //#####################################################################
   //# INTERFACE
   //#####################################################################
   //Parameters   
   parameter LAW  =  32;
   parameter IRQW =  10;
   
   //Basic Interface
   input             clk;       //main clock
   input             nreset;    //active low async reset

   //Sysreg Write Access
   input 	     reg_write;   //write signal
   input [5:0]       reg_addr;    //addr[5:0]
   input [31:0]      reg_wdata;   //data input
   
   //Control signals
   input [IRQW-1:0]  ext_irq;          //interrupt signals
   input [LAW-1:0]   sq_pc_next_ra;    //PC to save to IRET
   input 	     de_rti_e1;        //jump to IRET
   input 	     sq_global_irq_en; //disables all interrupts
   input 	     sq_ic_wait;       //wait until it's safe to interrupt (delete?)       
   output 	     ic_flush;         //flush pipeline to get rid if all instructions

   //Register Read Outputs
   output [LAW-1:0]  ic_iret_reg;      //interrupt return register
   output [IRQW-1:0] ic_imask_reg;     //interrupt mask register
   output [IRQW-1:0] ic_ilat_reg;      //latched ext_irq signals (but not started)
   output [IRQW-1:0] ic_ipend_reg;     //interrrupts pending/active
   
   //Interrupt Vector
   output 	     ic_irq;           //tells core to jump to adress in irq_addr
   output [LAW-1:0]  ic_irq_addr;      //interrupt vector

   //#####################################################################
   //# BODY
   //#####################################################################
   
   //For loop integers
   integer 	     i,j,m1,m2,n1,n2,p;  
   
   //Control registers
   reg [LAW-1:0]     ic_iret_reg;   
   reg [IRQW-1:0]    ic_ilat_reg;
   reg [IRQW-1:0]    ic_imask_reg;
   reg [IRQW-1:0]    ic_ipend_reg;
   reg [LAW-1:0]     ic_irq_addr;

   //Functions
   reg [IRQW-1:0]    ic_ilat_in;
   reg [IRQW-1:0]    ic_ilat_priority_en_n;
   reg [IRQW-1:0]    ic_ipend_priority_en_n;   
   reg [IRQW-1:0]    ic_irq_shadow;
   reg [IRQW-1:0]    ic_irq_entry;
   
   //Wires
   wire [IRQW-1:0]   ic_masked_ilat;   
   wire [LAW-1:0]    ic_ivt[IRQW-1:0];
   wire [IRQW-1:0]   ic_ipend_in;//changed to generate
   wire [IRQW:0]     ic_ipend_shifted_reg;
   wire [IRQW-1:0]   ic_imask_in;   
   wire [IRQW-1:0]   ic_irq_select;
   wire [IRQW-1:0]   ic_global_en;
   wire [IRQW-1:0]   ic_event;
   wire [IRQW-1:0]   ic_ilat_set_data;
   wire [IRQW-1:0]   ic_ilat_clear_data;
   
   wire 	     ic_write_imask;
   wire 	     ic_write_ipend;
   wire 	     ic_write_ilat;
   wire 	     ic_write_ilatset;
   wire 	     ic_write_ilatclr;
   wire 	     ic_write_iret;

   //###########################
   //ACCESS DECODE
   //########################### 
   assign ic_write_imask     = reg_write &(reg_addr[5:0] ==`ECORE_IMASK);   
   assign ic_write_ipend     = reg_write &(reg_addr[5:0] ==`ECORE_IPEND);
   assign ic_write_ilat      = reg_write &(reg_addr[5:0] ==`ECORE_ILAT);
   assign ic_write_ilatset   = reg_write &(reg_addr[5:0] ==`ECORE_ILATST);
   assign ic_write_ilatclr   = reg_write &(reg_addr[5:0] ==`ECORE_ILATCL);
   assign ic_write_iret      = reg_write & reg_addr[5:0] ==`ECORE_IRET; 


   //###########################
   //# RISING EDGE DETECTOR
   //########################### 
   always @ (posedge clk)    
     ic_irq_shadow[IRQW-1:0] <= ext_irq[IRQW-1:0] ;

   assign ic_event[IRQW-1:0]  = ext_irq[IRQW-1:0] & ~ic_irq_shadow[IRQW-1:0] ;

   
   //###########################
   //# ILAT
   //########################### 
   assign ic_ilat_set_data[IRQW-1:0]   =  reg_wdata[IRQW-1:0]  | 
					  ic_ilat_reg[IRQW-1:0];

   assign ic_ilat_clear_data[IRQW-1:0] = ~reg_wdata[IRQW-1:0]  & 
					  ic_ilat_reg[IRQW-1:0];
   
   always @*
     for(i=0;i<IRQW;i=i+1)     
       ic_ilat_in[i] =(ic_write_ilat    & reg_wdata[i])|         // explicit write
	              (ic_write_ilatset & ic_ilat_set_data[i]) | // ilatset
	              (ic_event[i])                            | // irq signal
	              (ic_ilat_reg[i]   &                        
		       ~(ic_write_ilatclr & reg_wdata[i]) & 
		       (sq_ic_wait | ~ic_irq_entry[i])
		       );                                        //isr entry clear

   //Don't clock gate the ILAT, should always be ready to recieve
   always @ (posedge clk or negedge nreset)
     if (!nreset)
       ic_ilat_reg[IRQW-1:0]  <= 'b0;   
     else
       ic_ilat_reg[IRQW-1:0]  <= ic_ilat_in[IRQW-1:0]; 
   

   //###########################
   //# IPEND
   //########################### 
   assign ic_ipend_shifted_reg[IRQW:0] = {ic_ipend_reg[IRQW-1:0],1'b0};
   
   genvar q;
   generate
      for(q=IRQW-1;q>=0;q=q-1) begin : gen_ipend
	assign ic_ipend_in[q]=(ic_irq_entry[q])              |
	                      (ic_ipend_reg[q] & ~de_rti_e1) | 
			      (|ic_ipend_shifted_reg[q:0]); //BUG?????
      end
   endgenerate

   always @ (posedge clk or negedge nreset)
     if (!nreset)
       ic_ipend_reg[IRQW-1:0] <= 'b0;   
     else if(ic_write_ipend)
       ic_ipend_reg[IRQW-1:0] <= reg_wdata[IRQW-1:0];
     else
       ic_ipend_reg[IRQW-1:0] <= ic_ipend_in[IRQW-1:0]; 

   
   //###########################
   //# IMASK
   //########################### 
   assign ic_imask_in[IRQW-1:0] = ic_write_imask ? reg_wdata[IRQW-1:0] : 
				                   ic_imask_reg[IRQW-1:0];
   
   always @ (posedge clk or negedge nreset)
     if (!nreset)
       ic_imask_reg[IRQW-1:0] <= 'b0;   
     else if(ic_write_imask)
       ic_imask_reg[IRQW-1:0] <= reg_wdata[IRQW-1:0];

   
   //###########################
   //# IRET
   //########################### 
   always @ (posedge clk)
     if(ic_flush)
       ic_iret_reg[LAW-1:0] <= sq_pc_next_ra[LAW-1:0];
     else if(ic_write_iret)
       ic_iret_reg[LAW-1:0] <= reg_wdata[LAW-1:0];		      

   //###########################
   //# IRQ VECTOR TABLE
   //########################### 
   genvar k;
   generate
      for(k=0;k<IRQW;k=k+1) begin: irqs
	 assign ic_ivt[k]=(`IRQ_VECTOR_TABLE+4*k);	     
      end
   endgenerate
        
   //mux
   always @*
     begin
	ic_irq_addr[LAW-1:0] = {(LAW){1'b0}};
	for(p=0;p<IRQW;p=p+1)
	  ic_irq_addr[LAW-1:0] = ic_irq_addr[LAW-1:0] | 
	                         ({(LAW){ic_irq_entry[p]}} & ic_ivt[p]);
     end

   //###########################
   //# PRIORITY CONTROLLER
   //########################### 
      
   //Masking interrupts
   assign ic_masked_ilat[IRQW-1:0]  = ic_ilat_reg[IRQW-1:0] & 
				      ~ic_imask_reg[IRQW-1:0];

   //Interrupt sent to sequencer if:
   //1.) no bit set in ipend for anything at that bit level or below
   //2.) global interrupt enable set
   //3.) no valid interrupt set at any bit lower than this one
  

   

   //ILAT PRIORITY
   //Keeps track of all higher priority ILATs that are not masked
   //This circuit is needed for the case when interrupts arrive simulataneously
   always @*
     begin     
	for(m1=IRQW-1;m1>0;m1=m1-1)
	  begin
	     ic_ilat_priority_en_n[m1]=1'b0;
             for(m2=m1-1;m2>=0;m2=m2-1)
	       ic_ilat_priority_en_n[m1]=ic_ilat_priority_en_n[m1] | ic_masked_ilat[m2];	  
	  end
	//No priority needed for bit[0], highest priority, so it's always enabled
	ic_ilat_priority_en_n[0]=1'b0;
     end


   //IPEND PRIORITY   
   always @*
     begin
	for(n1=IRQW-1;n1>=0;n1=n1-1)
	  begin
	     ic_ipend_priority_en_n[n1]=1'b0;   
	     for(n2=n1;n2>=0;n2=n2-1)
	       ic_ipend_priority_en_n[n1]=ic_ipend_priority_en_n[n1] | ic_ipend_reg[n2];//ic_ipend_reg[n2-1]	  
	  end
	//Bit zero has no IPEND priority: NO
	//ic_ipend_priority_en_n[0]=1'b0;
     end

   //Outgoing Interrupt (to sequencer)
   assign ic_irq_select[IRQW-1:0]= ic_masked_ilat[IRQW-1:0]          & //only if the ILAT bit is not masked by IMASK
                                   ~ic_ilat_priority_en_n[IRQW-1:0]  & //only if there is no masked ilat bit <current
	                           ~ic_ipend_priority_en_n[IRQW-1:0] & //only if there is no ipend bit <=current
                                    {(IRQW){sq_global_irq_en}};        //global vector for nested interrupts
   
   //Pipelining interrupt to account for stall signal
   //TODO: Understand this better...
   always @ (posedge clk)
     if(~sq_ic_wait)//includes fetch wait
       ic_irq_entry[IRQW-1:0] <= ic_irq_select[IRQW-1:0];// & ~ic_irq_entry[IRQW-1:0] ;
   
   assign ic_irq    =|(ic_irq_entry[IRQW-1:0]);
   
   //Flush for one cycle interrupt pulse
   assign ic_flush  =|(ic_irq_select[IRQW-1:0]);
   
endmodule // interrupt_controller

