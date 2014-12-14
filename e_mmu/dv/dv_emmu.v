//`timescale 1 ns / 100 ps
module dv_emmu();

   parameter DW   = 32;        //data width of
   parameter AW   = 32;        //data width of 
   parameter IW   = 12;        //index size of table
   parameter PAW  = 64;        //physical address width of output
   parameter MW   = PAW-AW+IW; //table data width
   parameter MD   = 1<<IW;     //memory depth

   
   //Stimulus to drive
   reg        clk;
   reg        reset;

   //Reg interface
   reg        mi_access;
   reg [12:0] mi_addr;
   reg [31:0] mi_data_in;
   reg 	      mi_write;

   //emesh interface
   reg              emesh_access_in;
   reg              emesh_write_in;
   reg [1:0]        emesh_datamode_in;
   reg [3:0]        emesh_ctrlmode_in;
   reg [AW-1:0]     emesh_dstaddr_in;
   reg [AW-1:0]     emesh_srcaddr_in;
   reg [DW-1:0]     emesh_data_in;
   
   //Test junk
   reg [1:0]  test_state;
   reg 	      go;
  
   //Reset
   initial
     begin
	$display($time, " << Starting the Simulation >>");	
	#0
        clk                    = 1'b0;    // at time 0
	reset                  = 1'b1;    // reset is active
	mi_write               = 1'b0;
	mi_access              = 1'b0;
	mi_addr[12:0]          = 13'b0;
	mi_data_in[31:0]       = 32'h55555000;
	test_state[1:0]        = 2'b00;
	go                     = 1'b0;		
        emesh_access_in        = 1'b0;
	emesh_write_in         = 1'b0;
	emesh_ctrlmode_in[3:0] = 4'b0;
	emesh_datamode_in[1:0] = 2'b0;
	emesh_dstaddr_in[31:0] = 32'b0;
	emesh_srcaddr_in[31:0] = 32'b0;
	emesh_data_in[31:0]    = 32'b0;
	#100 
	  reset    = 1'b0;    // at time 100 release reset
	#100
	  go       = 1'b1;	
	#10000	  
	  $finish;
     end

   //Clock
   always
     #10 clk = ~clk;

   //Pattern generator
   //1.) Write some patterns through mi_interface
   //2.) Write some patterns from emesh interface
      
   always @ (negedge clk)
     if(go)
       begin
	  case(test_state[1:0])
	    2'b00://write entries
	      if(mi_addr[12:0]<13'h16)
		begin
		   mi_access        <= 1'b1;
		   mi_write         <= 1'b1;
		   mi_addr[12:0]    <= mi_addr[12:0]   +1'b1;	  
		   mi_data_in[31:0] <= mi_addr[0] ? (mi_addr[12:0]+32'hFFFFF000) : 32'hFFFFFFFF;		   
		end
	      else
		begin
		   test_state       <= 2'b01;
		   mi_access        <= 1'b0;
		end
	    2'b01://
	      if(emesh_dstaddr_in[31:0]<32'h00800000)
		begin	    
		   emesh_access_in        <= 1'b1;
		   emesh_write_in         <= 1'b1;
		   emesh_dstaddr_in[31:0] <= emesh_dstaddr_in[31:0] + 32'h00100001;
		   emesh_ctrlmode_in[3:0] <= 4'b1111;
		   emesh_datamode_in[1:0] <= 2'b11;
		   emesh_data_in[31:0]    <= 32'h12345678;
		   emesh_srcaddr_in[31:0] <= 32'h55555555;
		end
	      else
		begin
		   test_state       <= 2'b10;
		   emesh_access_in <= 1'b0;
		end // else: !if(~done)
	    2'b10://init array
	      begin
		 mi_addr[5:0]     <= mi_addr[5:0]-1'b1;
	      end
	  endcase // case (test_state[1:0])
       end

   wire done =  (mi_addr[5:0]==6'b001101);
  
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			emesh_access_out;	// From emmu of emmu.v
   wire [3:0]		emesh_ctrlmode_out;	// From emmu of emmu.v
   wire [DW-1:0]	emesh_data_out;		// From emmu of emmu.v
   wire [1:0]		emesh_datamode_out;	// From emmu of emmu.v
   wire [PAW-1:0]	emesh_dstaddr_out;	// From emmu of emmu.v
   wire [AW-1:0]	emesh_srcaddr_out;	// From emmu of emmu.v
   wire			emesh_write_out;	// From emmu of emmu.v
   wire [DW-1:0]	mi_data_out;		// From emmu of emmu.v
   // End of automatics
   /*AUTOWIRE*/
   
   //DUT
   emmu emmu(
	     /*AUTOINST*/
	     // Outputs
	     .mi_data_out		(mi_data_out[DW-1:0]),
	     .emesh_access_out		(emesh_access_out),
	     .emesh_write_out		(emesh_write_out),
	     .emesh_datamode_out	(emesh_datamode_out[1:0]),
	     .emesh_ctrlmode_out	(emesh_ctrlmode_out[3:0]),
	     .emesh_dstaddr_out		(emesh_dstaddr_out[PAW-1:0]),
	     .emesh_srcaddr_out		(emesh_srcaddr_out[AW-1:0]),
	     .emesh_data_out		(emesh_data_out[DW-1:0]),
	     // Inputs
	     .reset			(reset),
	     .clk			(clk),
	     .mi_access			(mi_access),
	     .mi_write			(mi_write),
	     .mi_addr			(mi_addr[IW:0]),
	     .mi_data_in		(mi_data_in[DW-1:0]),
	     .emesh_access_in		(emesh_access_in),
	     .emesh_write_in		(emesh_write_in),
	     .emesh_datamode_in		(emesh_datamode_in[1:0]),
	     .emesh_ctrlmode_in		(emesh_ctrlmode_in[3:0]),
	     .emesh_dstaddr_in		(emesh_dstaddr_in[AW-1:0]),
	     .emesh_srcaddr_in		(emesh_srcaddr_in[AW-1:0]),
	     .emesh_data_in		(emesh_data_in[DW-1:0]));

   //Waveform dump
   initial
     begin
	$dumpfile("test.vcd");
	$dumpvars(0, dv_emmu);
     end

   
endmodule // dv_emmu


