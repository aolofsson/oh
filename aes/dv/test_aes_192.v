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

module test_aes_192;

	// Inputs
	reg clk;
	reg [127:0] state;
	reg [191:0] key;

	// Outputs
	wire [127:0] out;

	// Instantiate the Unit Under Test (UUT)
	aes_192 uut (
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
        key   = 192'h2b7e151628aed2a6abf7158809cf4f3c762e7160f38b4da5;
        #10;
        state = 128'h00112233445566778899aabbccddeeff;
        key   = 192'h000102030405060708090a0b0c0d0e0f1011121314151617;
        #10;
        state = 128'h0;
        key   = 192'h0;
        #230;
        if (out !== 128'hf9fb29aefc384a250340d833b87ebc00)
          begin $display("E"); $finish; end
        #10;
        if (out !== 128'hdda97ca4864cdfe06eaf70a0ec0d7191)
          begin $display("E"); $finish; end
        $display("Good.");
        $finish;
	end
      
    always #5 clk = ~clk;
endmodule

