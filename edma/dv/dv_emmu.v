//`timescale 1 ns / 100 ps
module dv_emmu
  (input clk,
   input reset,
   input go);

   parameter DW   = 32;        //data width of
   parameter AW   = 32;        //data width of 
   parameter IW   = 12;        //index size of table
   parameter PAW  = 64;        //physical address width of output
   parameter MW   = PAW-AW+IW; //table data width
   parameter MD   = 1<<IW;     //memory depth

   
   //Stimulus to drive
   reg 	      mmu_en;
   
   //Reg interface
   reg        mi_en;
   reg [12:0] mi_addr;
   reg [31:0] mi_din;
   reg [3:0]  mi_we;
   
   
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
  
   //Pattern generator
   //1.) Write some patterns through mi_interface
   //2.) Write some patterns from emesh interface
      
   always @ (negedge clk) begin
     if(go)
       begin
	  case(test_state[1:0])
	    2'b00://write entries
	      if(mi_addr[12:0]<13'h16)
		begin
		   mi_en            <= 1'b1;
		   mi_we[3:0]       <= 4'b1111;
		   mi_addr[12:0]    <= mi_addr[12:0] + 1'b1;	  
		   /* verilator lint_off WIDTH */
		   mi_din[31:0]     <= mi_addr[0] ? (mi_addr[12:0]+32'hFFFFF000) : 32'hFFFFFFFF;
		   /* verilator lint_on WIDTH */
		end
	      else
		begin
		   test_state       <= 2'b01;
		   mi_en            <= 1'b0;
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
	    default : test_state <= test_state;
	  endcase // case (test_state[1:0])
       end // if (go)
      if (reset) begin
	 mi_we[3:0]             <= 4'b0;
	 mi_en                  <= 1'b0;
	 mi_addr[12:0]          <= 13'b0;
	 mi_din[31:0]           <= 32'h55555000;
	 test_state[1:0]        <= 2'b00;
         emesh_access_in        <= 1'b0;
	 emesh_write_in         <= 1'b0;
	 emesh_ctrlmode_in[3:0] <= 4'b0;
	 emesh_datamode_in[1:0] <= 2'b0;
	 emesh_dstaddr_in[31:0] <= 32'b0;
	 emesh_srcaddr_in[31:0] <= 32'b0;
	 emesh_data_in[31:0]    <= 32'b0;
	 mmu_en                 <= 1'b1;
     end
   end
   wire done =  (mi_addr[5:0]==6'b001101);
  
   
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   wire			emmu_access_out;	// From emmu of emmu.v
   wire [3:0]		emmu_ctrlmode_out;	// From emmu of emmu.v
   wire [DW-1:0]	emmu_data_out;		// From emmu of emmu.v
   wire [1:0]		emmu_datamode_out;	// From emmu of emmu.v
   wire [63:0]		emmu_dstaddr_out;	// From emmu of emmu.v
   wire [AW-1:0]	emmu_srcaddr_out;	// From emmu of emmu.v
   wire			emmu_write_out;		// From emmu of emmu.v
   wire [31:0]		mi_dout;		// From emmu of emmu.v
   // End of automatics
   /*AUTOWIRE*/
   
   //DUT
   emmu emmu(.mi_clk			(clk),
	     /*AUTOINST*/
	     // Outputs
	     .mi_dout			(mi_dout[31:0]),
	     .emmu_access_out		(emmu_access_out),
	     .emmu_write_out		(emmu_write_out),
	     .emmu_datamode_out		(emmu_datamode_out[1:0]),
	     .emmu_ctrlmode_out		(emmu_ctrlmode_out[3:0]),
	     .emmu_dstaddr_out		(emmu_dstaddr_out[63:0]),
	     .emmu_srcaddr_out		(emmu_srcaddr_out[AW-1:0]),
	     .emmu_data_out		(emmu_data_out[DW-1:0]),
	     // Inputs
	     .clk			(clk),
	     .mmu_en			(mmu_en),
	     .mi_en			(mi_en),
	     .mi_we			(mi_we[3:0]),
	     .mi_addr			({3'b000,mi_addr[12:0]}),
	     .mi_din			(mi_din[31:0]),
	     .emesh_access_in		(emesh_access_in),
	     .emesh_write_in		(emesh_write_in),
	     .emesh_datamode_in		(emesh_datamode_in[1:0]),
	     .emesh_ctrlmode_in		(emesh_ctrlmode_in[3:0]),
	     .emesh_dstaddr_in		(emesh_dstaddr_in[AW-1:0]),
	     .emesh_srcaddr_in		(emesh_srcaddr_in[AW-1:0]),
	     .emesh_data_in		(emesh_data_in[DW-1:0]));

   
endmodule // dv_emmu
// Local Variables:
// verilog-library-directories:("." "../hdl")
// End:



