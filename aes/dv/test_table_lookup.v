/*
 * Copyright 2012, Homer Hsing <homer.hsing@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

`timescale 1ns / 1ps

module test_table_lookup;

	// Inputs
	reg clk;
	reg [31:0] state;

	// Outputs
	wire [31:0] p0;
	wire [31:0] p1;
	wire [31:0] p2;
	wire [31:0] p3;

	// Instantiate the Unit Under Test (UUT)
	table_lookup uut (
		.clk(clk), 
		.state(state), 
		.p0(p0), 
		.p1(p1), 
		.p2(p2), 
		.p3(p3)
	);

	initial begin
		clk = 0;
		state = 0;
		#100;
        state = 31'h193de3be;
        #10;
        if (p0 !== 32'hb3_d4_d4_67) begin $display("E"); $finish; end
        if (p1 !== 32'h69_4e_27_27) begin $display("E"); $finish; end
        if (p2 !== 32'h11_33_22_11) begin $display("E"); $finish; end
        if (p3 !== 32'hae_ae_e9_47) begin $display("E"); $finish; end
        $display("Good.");
        $finish;
	end
    
    always #5 clk = ~clk;
endmodule

