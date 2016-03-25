/*
===============================================================
10 bit to 8 bit decoder
===============================================================
*/
// File Name:		oh_8b10b_decode.v
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

module oh_8b10b_decode(
			input		clk,			//Input Clock
			input		nreset,			//Synchronous Active-Low reset

			input		[9:0]	rx_code_group,  //10 - bit input
			
			output	reg		K_out,		//K group output
			output	reg	[7:0]	code_group,	//8 - bit output
			output	reg		code_error,	//Code error outputi
			output	reg		disp_error	//Disparity Error
		  );



wire [5:0] code_6b;
wire [3:0] code_4b;

reg [9:0] rx_code_group_latch;
reg [4:0] dec_5b;
reg [2:0] dec_3b;
reg flag_5;
reg flag_3;

wire [2:0] bit6_disp;
wire [2:0] bit4_disp;

wire [7:0] code_group_temp;
wire	   K_out_temp;
wire	   code_error_temp;

wire bit_6rd;
wire bit_4rd;

reg K_found;
wire RD_p;
wire RD;
wire RD_eq;
wire RD_n;

reg disparity;

assign  code_group_temp = {dec_3b, dec_5b};
assign	code_6b = rx_code_group_latch[9:4];
assign	code_4b = rx_code_group_latch[3:0];

assign	code_error_temp = ((((dec_5b == 5'd0) & (flag_5)) | ((dec_3b == 3'o0) & (~flag_3))));// | disp_error);
assign	K_out_temp	   = (flag_5 & flag_3 & K_found);

assign bit6_disp = (code_6b[5] + code_6b[4] + code_6b[3] + code_6b[2] + code_6b[1] + code_6b[0]);

assign bit4_disp = (code_4b[3] + code_4b[2] + code_4b[1] + code_4b[0]);

assign bit_6rd = (bit6_disp > 'd3) & (bit6_disp != 'd3);
assign bit_4rd = (bit4_disp > 'd2) & (bit4_disp != 'd2);

assign RD = (bit6_disp == 'd3 & bit4_disp == 'd2) ? disparity : ((bit4_disp == 'd2) ? bit_6rd : bit_4rd); 
assign RD_eq = (bit6_disp == 'd3 & bit4_disp == 'd2);
assign RD_p = (bit4_disp == 'd2) ? bit_6rd : bit_4rd;  
assign RD_n = (bit4_disp == 'd2) ? (~bit_6rd) : (~bit_4rd);  

	always@(posedge clk)
		begin

		if(~nreset)
			begin
			disparity <= 1'b0;
			code_group <= 8'hBC;
			K_out	   <= 1'b0;
			disp_error <= 1'b0;
			code_error <= 1'b0;
			rx_code_group_latch <= 10'd0;
			end
		else
			begin
			code_group		<=	code_group_temp;
			K_out			<=	K_out_temp;
			rx_code_group_latch	<=	rx_code_group;
			
			if((disparity & (RD_eq | RD_p)) | ((~disparity) & (RD_eq | RD_n)))
				begin
					disp_error <= 1'b0;
				end
			else	
				begin
					disp_error <= 1'b1;
				end
					disparity <= RD;

			code_error	<=	code_error_temp;
			end
		end

	always@(*)
		begin
			case(code_6b)

				6'o47, 6'o30 	: begin dec_5b = 5'd0 ; flag_5 = 1'b0; end 	
				6'o35, 6'o42 	: begin dec_5b = 5'd1 ; flag_5 = 1'b0; end 	
				6'o55, 6'o22 	: begin dec_5b = 5'd2 ; flag_5 = 1'b0; end 	
				6'o61 		: begin dec_5b = 5'd3 ; flag_5 = 1'b0; end 	
				6'o65, 6'o12 	: begin dec_5b = 5'd4 ; flag_5 = 1'b0; end 	
				6'o51	 	: begin dec_5b = 5'd5 ; flag_5 = 1'b0; end 	
				6'o31	 	: begin dec_5b = 5'd6 ; flag_5 = 1'b0; end 	
				6'o70, 6'o07 	: begin dec_5b = 5'd7 ; flag_5 = 1'b0; end 	
				6'o71, 6'o06 	: begin dec_5b = 5'd8 ; flag_5 = 1'b0; end 	
				6'o45	 	: begin dec_5b = 5'd9 ; flag_5 = 1'b0; end 	
				6'o25	 	: begin dec_5b = 5'd10 ; flag_5 = 1'b0; end 	
				6'o64	 	: begin dec_5b = 5'd11 ; flag_5 = 1'b0; end 	
				6'o15	 	: begin dec_5b = 5'd12 ; flag_5 = 1'b0; end 	
				6'o54	 	: begin dec_5b = 5'd13 ; flag_5 = 1'b0; end 	
				6'o34	 	: begin dec_5b = 5'd14 ; flag_5 = 1'b0; end 	
				6'o27, 6'o50 	: begin dec_5b = 5'd15 ; flag_5 = 1'b0; end 	
				6'o33, 6'o44 	: begin dec_5b = 5'd16 ; flag_5 = 1'b0; end 	
				6'o43	 	: begin dec_5b = 5'd17 ; flag_5 = 1'b0; end 	
				6'o23	 	: begin dec_5b = 5'd18 ; flag_5 = 1'b0; end 	
				6'o62		: begin dec_5b = 5'd19 ; flag_5 = 1'b0; end 	
				6'o13		: begin dec_5b = 5'd20 ; flag_5 = 1'b0; end 	
				6'o52		: begin dec_5b = 5'd21 ; flag_5 = 1'b0; end 	
				6'o32		: begin dec_5b = 5'd22 ; flag_5 = 1'b0; end 	
				6'o72, 6'o05 	: begin dec_5b = 5'd23 ; flag_5 = 1'b1; end 	
				6'o63, 6'o14 	: begin dec_5b = 5'd24 ; flag_5 = 1'b0; end 	
				6'o46		: begin dec_5b = 5'd25 ; flag_5 = 1'b0; end 	
				6'o26		: begin dec_5b = 5'd26 ; flag_5 = 1'b0; end 	
				6'o66, 6'o11 	: begin dec_5b = 5'd27 ; flag_5 = 1'b1; end 	
				6'o16		: begin dec_5b = 5'd28 ; flag_5 = 1'b0; end 	
				6'o17, 6'o60	: begin dec_5b = 5'd28 ; flag_5 = 1'b1; end 	
				6'o56, 6'o21 	: begin dec_5b = 5'd29 ; flag_5 = 1'b1; end 	
				6'o36, 6'o41 	: begin dec_5b = 5'd30 ; flag_5 = 1'b1; end 	
				6'o53, 6'o24 	: begin dec_5b = 5'd31 ; flag_5 = 1'b0; end 	
				default	 	: begin dec_5b = 5'd0 ; flag_5 = 1'b1; end 
			endcase
		end
	
	always@(*)
		begin
			case(code_4b)
				
				4'h4 , 4'hb	: begin dec_3b = 3'o0 ; flag_3 = 1'b1; end 
				4'h9 		: begin dec_3b = 3'o1 ; flag_3 = 1'b1; end 
				4'h5 		: begin dec_3b = 3'o2 ; flag_3 = 1'b1; end 
				4'h3 , 4'hc	: begin dec_3b = 3'o3 ; flag_3 = 1'b1; end 
				4'h2 , 4'hd	: begin dec_3b = 3'o4 ; flag_3 = 1'b1; end 
				4'ha 		: begin dec_3b = 3'o5 ; flag_3 = 1'b1; end 
				4'h6 		: begin dec_3b = 3'o6 ; flag_3 = 1'b1; end 
				4'h1 , 4'he 	: begin dec_3b = 3'o7 ; flag_3 = 1'b0; end 
				4'h8 , 4'h7	: begin dec_3b = 3'o7 ; flag_3 = 1'b1; end 
				default		: begin dec_3b = 3'o0 ; flag_3 = 1'b0; end 

			endcase

		end

	always@(*)
		begin
			case(code_group_temp)				
				8'h1C		: K_found = 1'b1;
				8'h3C		: K_found = 1'b1;
				8'h5C		: K_found = 1'b1;
				8'h7C		: K_found = 1'b1;
				8'h9C		: K_found = 1'b1;
				8'hBC		: K_found = 1'b1;
				8'hDC		: K_found = 1'b1;
				8'hFC		: K_found = 1'b1;
				8'hF7		: K_found = 1'b1;
				8'hFB		: K_found = 1'b1;
				8'hFD		: K_found = 1'b1;
				8'hFE		: K_found = 1'b1;
				default		: K_found = 1'b0;
			endcase
		end
endmodule
