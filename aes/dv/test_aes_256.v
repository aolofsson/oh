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

module test_aes_256;

	// Inputs
	reg clk;
	reg [127:0] state;
	reg [255:0] key;

	// Outputs
	wire [127:0] out;

	// Instantiate the Unit Under Test (UUT)
	aes_256 uut (
		.clk(clk), 
		.state(state), 
		.key(key), 
		.out(out)
	);

	initial begin
		clk = 0;
		state = 0;
		key = 0;

		#100;
        /*
         * TIMEGRP "key" OFFSET = IN 6.4 ns VALID 6 ns AFTER "clk" HIGH;
         * TIMEGRP "state" OFFSET = IN 6.4 ns VALID 6 ns AFTER "clk" HIGH;
         * TIMEGRP "out" OFFSET = OUT 2.2 ns BEFORE "clk" HIGH;
         */
        @ (negedge clk);
        #2;
        state = 128'h3243f6a8885a308d313198a2e0370734;
        key   = 256'h2b7e151628aed2a6abf7158809cf4f3c_762e7160f38b4da56a784d9045190cfe;
        #10;
        state = 128'h00112233445566778899aabbccddeeff;
        key   = 256'h000102030405060708090a0b0c0d0e0f_101112131415161718191a1b1c1d1e1f;
        #10;
        state = 128'h0;
        key   = 256'h0;
        #270;
        if (out !== 128'h1a6e6c2c_662e7da6_501ffb62_bc9e93f3)
          begin $display("E"); $finish; end
        #10;
        if (out !== 128'h8ea2b7ca_516745bf_eafc4990_4b496089)
          begin $display("E"); $finish; end
        $display("Good.");
        $finish;
	end
      
    always #5 clk = ~clk;
endmodule

