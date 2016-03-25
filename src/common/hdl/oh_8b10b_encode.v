/*
===============================================================
8 bit to 10 bit Encoder
===============================================================
*/
// File Name:		oh_8b10b_encode.v
// Version:		1.0v
//
// Author:		Prasad Pandit
// Contact:		prasadp4009@gmail.com/prasad@pdx.edu
//
// Date created:	03/19/2016
// Date modified:	03/19/2016
//
// Text-editor used:	Gvim 7v4 & NPP
//
// ************************************************************

module oh_8b10b_encode(
	input		clk,
	input		nreset,
	input		ksel,
	input [7:0] 	data_in,
	input		disp_in,
	
	output		RD_out,
	output	[9:0] 	data_out
   );
   
reg 		ksel_latch;
reg 		disparity_latch;
reg [7:0]	data_in_latch;
reg [9:0]	data_out_latch;
reg 		RD_latch;

wire [9:0]	data_out_wire;
wire		disparity;
wire [7:0]	TXD;
wire		K;
wire [9:0]	code_group;

//----------------Signals to be used-----------
wire 	[4:0] TXD_5;
wire 	[2:0] TXD_3;

wire 	A,B,C,D,E,F,G,H;
wire 	a,b,c,d,e,i_rdp,i_rdn,f,g,h,j;

wire 	NA,NB,NC,ND,NE;

wire 	[2:0] bit6_disp;
wire 	[2:0] bit4_disp;

wire	[5:0] code_6b;
wire	[3:0] code_4b;

wire	bit_6rd;
wire	bit_4rd;

wire 	invert_6;
wire	invert_4;	
wire	invert_3b4;
wire	spe_4bp, spe_4bn;

wire	k_j;
wire	k_i;

assign RD_out 		= RD_latch;
assign data_out 	= data_out_latch;
assign TXD 		= data_in_latch;
assign K 		= ksel_latch;
assign disparity 	= disparity_latch;
assign data_out_wire 	= code_group;

//----------------------------------------------
//---------------Code Group Output--------------

assign code_group = {code_6b,code_4b};

//----------------------------------------------
//---------------TXD to 5 bit and 3 bit---------

assign TXD_5 = TXD[4:0];
assign TXD_3 = TXD[7:5];

//----------------------------------------------

//----------------Special Code Group Logic----------------------------------------------------------------------------------------------------------

assign k_i = (TXD[4:0] == 5'b11100); 
assign k_j = (TXD[7:5] == 3'b111);
//----------------------------------------------

assign invert_6 = ((TXD_5 == 'd0) | (TXD_5 == 'd1) | (TXD_5 == 'd2) | (TXD_5 == 'd4) | (TXD_5 == 'd7) | (TXD_5 == 'd8) 
		| (TXD_5 == 'd15) | (TXD_5 == 'd16) | (TXD_5 == 'd23) | (TXD_5 == 'd24) | (TXD_5 == 'd27) | 
		(TXD_5 == 'd29) | (TXD_5 == 'd30) | (TXD_5 == 'd31));  

assign invert_4 = ((TXD_3 == 'd0) | (TXD_3 == 'd3) | (TXD_3 == 'd4) | (TXD_3 == 'd7));

assign invert_3b4 = ((TXD_5 == 'd0) | (TXD_5 == 'd1) | (TXD_5 == 'd2) | (TXD_5 == 'd4) | (TXD_5 == 'd8) | 
		    (TXD_5 == 'd15) | (TXD_5 == 'd16) | (TXD_5 == 'd23) | (TXD_5 == 'd24) | (TXD_5 == 'd27) |
		    (TXD_5 == 'd29) | (TXD_5 == 'd30) | (TXD_5 == 'd31));// | (K & TXD_5 ==k_i & ~disparity); 

assign spe_4bp = ((TXD == 'hEB) | (TXD == 'hED) | (TXD == 'hEE));
assign spe_4bn = ((TXD == 'hF1) | (TXD == 'hF2) | (TXD == 'hF4));

assign bit6_disp = (code_6b[5] + code_6b[4] + code_6b[3] + code_6b[2] + code_6b[1] + code_6b[0]);

assign bit4_disp = (code_4b[3] + code_4b[2] + code_4b[1] + code_4b[0]);

assign bit_6rd = (bit6_disp > 'd3) & (bit6_disp != 'd3);
assign bit_4rd = (bit4_disp > 'd2) & (bit4_disp != 'd2);

assign RD = (bit6_disp == 'd3 & bit4_disp == 'd2) ? disparity : ((bit4_disp == 'd2) ? bit_6rd : bit_4rd); 

assign code_6b[5] = K ? (disparity ? NA : A ):
	                ((disparity & invert_6) ? ~a : a);

assign code_6b[4] = K ? (disparity ? NB : B) : 
                        ((disparity & invert_6) ? ~b : b);

assign code_6b[3] = K ? (disparity ? NC : C) : 
			((disparity & invert_6) ? ~c : c);

assign code_6b[2] = K ? (disparity ? ND : D) : 
			((disparity & invert_6) ? ~d : d);

assign code_6b[1] = K ? (disparity ? NE : E) : 
			((disparity & invert_6) ? ~e : e);

assign code_6b[0] = K ? (disparity ? ~k_i : k_i) : 
			((disparity & invert_6) ? i_rdp: i_rdn);

assign code_4b[3] = (disparity)  ? ((k_j & K) ? 'b0 : (K ? ~f : (spe_4bp ? 'b1 : ((invert_4) ? (invert_3b4 ? ~f : f): f)))) :
				   ((k_j & K) ? 'b1 : (K ? f :(spe_4bn ? 'b0 :((invert_4) ? (invert_3b4 ? f : ~f) : f))));

assign code_4b[2] = (disparity)  ? ((k_j & K) ? 'b1 : (K ? ~g :(spe_4bp ? 'b0 : ((invert_4) ? (invert_3b4 ? ~g : g) : g)))) : 
                                   ((k_j & K) ? 'b0 : (K ? g  :(spe_4bn ? 'b1 :((invert_4) ? (invert_3b4 ? g : ~g)  : g))));

assign code_4b[1] = (disparity)  ? ((k_j & K) ? 'b1 : (K ? ~h :(spe_4bp ? 'b0 : ((invert_4) ? (invert_3b4? ~h : h) : h)))) : 
				   ((k_j & K) ? 'b0 : (K ? h  :(spe_4bn ? 'b1 :((invert_4) ? (invert_3b4 ? h : ~h) : h))));

assign code_4b[0] = (disparity)  ? ((k_j & K) ? 'b1 : (K ? ~j :(spe_4bp ? 'b0 : ((invert_4) ? (invert_3b4 ? ~j : j): j)))) : 
                                   ((k_j & K) ? 'b0 : (K ? j :(spe_4bn ? 'b1 :((invert_4) ? (invert_3b4 ? j : ~j) : j))));

assign A = TXD[0];
assign B = TXD[1];
assign C = TXD[2];
assign D = TXD[3];
assign E = TXD[4];

assign F = TXD[5];
assign G = TXD[6];
assign H = TXD[7];

assign NA = ~A;
assign NB = ~B;
assign NC = ~C;
assign ND = ~D;
assign NE = ~E;

assign NF = ~F;
assign NG = ~G;
assign NH = ~H;

//----------------Data Code Group Logic----------------------------------------------------------------------------------------------------------

assign a = (E & A) | (NE & ND & NB & NA) | (NE & D & NB & A) | (NE & ND & B & A) | (NE & ND & NC & B)
                    | (C & NB & A) | (NC & B & A) | (NC & NB & D);

assign b = (E & B & NA) | (ND & B & A)| (NE & D & B) |(D & NC & B) 
                    |(NE & C & B) |(NE & ND & C & NA) |(NE & ND & NC & A) |(NC & NB & NA & D) |(NC & NB & NA & E) ; 

assign c = (NE & ND & B & NA) | (NE & ND & NB & A) | 
                    (NE & D & NB & NA) | (E & ND & NB & NA) | (NE & ND & C & B) | (E & C & B)  | (C & NB & A) | (E & C & NB) | (C & B & NA);

assign d = (NE & ND & NB & NA) | (NE & ND & NC & NB) | (NE & NC & B & NA) | (D & NB & A) | (D & B & NA) 
			| (NE & D & B) | (E & D & NC & B) | (D & C & NB & NA);

assign e = E | (ND & NC & NB & NA) | (D & C & B & A);

assign i_rdn = (NE & NB & NA) | (ND & NB & NA) | (NE & ND & B & NA) | (NE & ND & NB) | (D & C & B & A) 
		    | (ND & NC & NA) | (E & ND & NC & NB) | (NE & NC & NB & A) | (NC & NB & NA) | (NE & ND & NC) | (NE & NC & B & NA);

assign i_rdp = (NE & ND & ((B & A) | (C & B) | (C & A))) | (NC & B & NA & (E ^ D)) | (E & D & C & (B ^ A)) | (E & ND & C & ((B & A) | (NB & NA)))
		| (NE & D & NC & NB & A) | (E & D & NC & B & A) | (E & ND & NC & NB & A) | (NE & D & C & NB & NA);

assign f = (NG & F);

assign g = (NF & (NH | G));

assign h = (H & (NG | NF)) | (NH & G & F);

assign j = (NH & (F | G)) | (G & F);
//----------------------------------------------------------------------X-------------------------------------------------------------------------

always@(posedge clk or negedge nreset)
begin
	if(~nreset)
	begin
		ksel_latch <= 1'd0;
		disparity_latch <= 1'd0;
		data_in_latch <= 8'd0;
		RD_latch	<= 1'd0;
		data_out_latch <= 10'd0;
	end
	else
	begin
		ksel_latch <= ksel;
		data_in_latch <= data_in;
		disparity_latch <= disp_in;
		RD_latch <= RD;
		data_out_latch <= data_out_wire;
	end
end

endmodule

			
