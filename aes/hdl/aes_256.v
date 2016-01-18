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

module aes_256 (clk, state, key, out);
    input          clk;
    input  [127:0] state;
    input  [255:0] key;
    output [127:0] out;
    reg    [127:0] s0;
    reg    [255:0] k0, k0a, k1;
    wire   [127:0] s1, s2, s3, s4, s5, s6, s7, s8,
                   s9, s10, s11, s12, s13;
    wire   [255:0] k2, k3, k4, k5, k6, k7, k8,
                   k9, k10, k11, k12, k13;
    wire   [127:0] k0b, k1b, k2b, k3b, k4b, k5b, k6b, k7b, k8b,
                   k9b, k10b, k11b, k12b, k13b;

    always @ (posedge clk)
      begin
        s0 <= state ^ key[255:128];
        k0 <= key;
        k0a <= k0;
        k1 <= k0a;
      end

    assign k0b = k0a[127:0];

    expand_key_type_A_256
        a1 (clk, k1, 8'h1, k2, k1b),
        a3 (clk, k3, 8'h2, k4, k3b),
        a5 (clk, k5, 8'h4, k6, k5b),
        a7 (clk, k7, 8'h8, k8, k7b),
        a9 (clk, k9, 8'h10, k10, k9b),
        a11 (clk, k11, 8'h20, k12, k11b),
        a13 (clk, k13, 8'h40,    , k13b);

    expand_key_type_B_256
        a2 (clk, k2, k3, k2b),
        a4 (clk, k4, k5, k4b),
        a6 (clk, k6, k7, k6b),
        a8 (clk, k8, k9, k8b),
        a10 (clk, k10, k11, k10b),
        a12 (clk, k12, k13, k12b);
    
    one_round
         r1 (clk, s0, k0b, s1),
         r2 (clk, s1, k1b, s2),
         r3 (clk, s2, k2b, s3),
         r4 (clk, s3, k3b, s4),
         r5 (clk, s4, k4b, s5),
         r6 (clk, s5, k5b, s6),
         r7 (clk, s6, k6b, s7),
         r8 (clk, s7, k7b, s8),
         r9 (clk, s8, k8b, s9),
        r10 (clk, s9, k9b, s10),
        r11 (clk, s10, k10b, s11),
        r12 (clk, s11, k11b, s12),
        r13 (clk, s12, k12b, s13);

    final_round
        rf (clk, s13, k13b, out);
endmodule

/* expand k0,k1,k2,k3 for every two clock cycles */
module expand_key_type_A_256 (clk, in, rcon, out_1, out_2);
    input              clk;
    input      [255:0] in;
    input      [7:0]   rcon;
    output reg [255:0] out_1;
    output     [127:0] out_2;
    wire       [31:0]  k0, k1, k2, k3, k4, k5, k6, k7,
                       v0, v1, v2, v3;
    reg        [31:0]  k0a, k1a, k2a, k3a, k4a, k5a, k6a, k7a;
    wire       [31:0]  k0b, k1b, k2b, k3b, k4b, k5b, k6b, k7b, k8a;

    assign {k0, k1, k2, k3, k4, k5, k6, k7} = in;
    
    assign v0 = {k0[31:24] ^ rcon, k0[23:0]};
    assign v1 = v0 ^ k1;
    assign v2 = v1 ^ k2;
    assign v3 = v2 ^ k3;

    always @ (posedge clk)
        {k0a, k1a, k2a, k3a, k4a, k5a, k6a, k7a} <= {v0, v1, v2, v3, k4, k5, k6, k7};

    S4
        S4_0 (clk, {k7[23:0], k7[31:24]}, k8a);

    assign k0b = k0a ^ k8a;
    assign k1b = k1a ^ k8a;
    assign k2b = k2a ^ k8a;
    assign k3b = k3a ^ k8a;
    assign {k4b, k5b, k6b, k7b} = {k4a, k5a, k6a, k7a};

    always @ (posedge clk)
        out_1 <= {k0b, k1b, k2b, k3b, k4b, k5b, k6b, k7b};

    assign out_2 = {k0b, k1b, k2b, k3b};
endmodule

/* expand k4,k5,k6,k7 for every two clock cycles */
module expand_key_type_B_256 (clk, in, out_1, out_2);
    input              clk;
    input      [255:0] in;
    output reg [255:0] out_1;
    output     [127:0] out_2;
    wire       [31:0]  k0, k1, k2, k3, k4, k5, k6, k7,
                       v5, v6, v7;
    reg        [31:0]  k0a, k1a, k2a, k3a, k4a, k5a, k6a, k7a;
    wire       [31:0]  k0b, k1b, k2b, k3b, k4b, k5b, k6b, k7b, k8a;

    assign {k0, k1, k2, k3, k4, k5, k6, k7} = in;
    
    assign v5 = k4 ^ k5;
    assign v6 = v5 ^ k6;
    assign v7 = v6 ^ k7;

    always @ (posedge clk)
        {k0a, k1a, k2a, k3a, k4a, k5a, k6a, k7a} <= {k0, k1, k2, k3, k4, v5, v6, v7};

    S4
        S4_0 (clk, k3, k8a);

    assign {k0b, k1b, k2b, k3b} = {k0a, k1a, k2a, k3a};
    assign k4b = k4a ^ k8a;
    assign k5b = k5a ^ k8a;
    assign k6b = k6a ^ k8a;
    assign k7b = k7a ^ k8a;

    always @ (posedge clk)
        out_1 <= {k0b, k1b, k2b, k3b, k4b, k5b, k6b, k7b};

    assign out_2 = {k4b, k5b, k6b, k7b};
endmodule

