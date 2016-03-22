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

module aes_192 (clk, state, key, out);
    input          clk;
    input  [127:0] state;
    input  [191:0] key;
    output [127:0] out;
    reg    [127:0] s0;
    reg    [191:0] k0;
    wire   [127:0] s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11;
    wire   [191:0] k1, k2, k3, k4, k5, k6, k7, k8, k9, k10, k11;
    wire   [127:0] k0b, k1b, k2b, k3b, k4b, k5b, k6b, k7b, k8b, k9b, k10b, k11b;

    always @ (posedge clk)
      begin
        s0 <= state ^ key[191:64];
        k0 <= key;
      end

    expand_key_type_D_192  a0 (clk, k0, 8'h1,   k1,  k0b);
    expand_key_type_B_192  a1 (clk, k1,         k2,  k1b);
    expand_key_type_A_192  a2 (clk, k2, 8'h2,   k3,  k2b);
    expand_key_type_C_192  a3 (clk, k3, 8'h4,   k4,  k3b);
    expand_key_type_B_192  a4 (clk, k4,         k5,  k4b);
    expand_key_type_A_192  a5 (clk, k5, 8'h8,   k6,  k5b);
    expand_key_type_C_192  a6 (clk, k6, 8'h10,  k7,  k6b);
    expand_key_type_B_192  a7 (clk, k7,         k8,  k7b);
    expand_key_type_A_192  a8 (clk, k8, 8'h20,  k9,  k8b);
    expand_key_type_C_192  a9 (clk, k9, 8'h40, k10,  k9b);
    expand_key_type_B_192 a10 (clk,k10,        k11, k10b);
    expand_key_type_A_192 a11 (clk,k11, 8'h80,    , k11b);

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
        r11 (clk, s10, k10b, s11);

    final_round
        rf (clk, s11, k11b, out);
endmodule

/* expand k0,k1,k2,k3 for every two clock cycles */
module expand_key_type_A_192 (clk, in, rcon, out_1, out_2);
    input              clk;
    input      [191:0] in;
    input      [7:0]   rcon;
    output reg [191:0] out_1;
    output     [127:0] out_2;
    wire       [31:0]  k0, k1, k2, k3, k4, k5,
                       v0, v1, v2, v3;
    reg        [31:0]  k0a, k1a, k2a, k3a, k4a, k5a;
    wire       [31:0]  k0b, k1b, k2b, k3b, k4b, k5b, k6a;

    assign {k0, k1, k2, k3, k4, k5} = in;
    
    assign v0 = {k0[31:24] ^ rcon, k0[23:0]};
    assign v1 = v0 ^ k1;
    assign v2 = v1 ^ k2;
    assign v3 = v2 ^ k3;

    always @ (posedge clk)
        {k0a, k1a, k2a, k3a, k4a, k5a} <= {v0, v1, v2, v3, k4, k5};

    S4
        S4_0 (clk, {k5[23:0], k5[31:24]}, k6a);

    assign k0b = k0a ^ k6a;
    assign k1b = k1a ^ k6a;
    assign k2b = k2a ^ k6a;
    assign k3b = k3a ^ k6a;
    assign {k4b, k5b} = {k4a, k5a};

    always @ (posedge clk)
        out_1 <= {k0b, k1b, k2b, k3b, k4b, k5b};

    assign out_2 = {k0b, k1b, k2b, k3b};
endmodule

/* expand k2,k3,k4,k5 for every two clock cycles */
module expand_key_type_B_192 (clk, in, out_1, out_2);
    input              clk;
    input      [191:0] in;
    output reg [191:0] out_1;
    output     [127:0] out_2;
    wire       [31:0]  k0, k1, k2, k3, k4, k5,
                       v2, v3, v4, v5;
    reg        [31:0]  k0a, k1a, k2a, k3a, k4a, k5a;

    assign {k0, k1, k2, k3, k4, k5} = in;
    
    assign v2 = k1 ^ k2;
    assign v3 = v2 ^ k3;
    assign v4 = v3 ^ k4;
    assign v5 = v4 ^ k5;

    always @ (posedge clk)
        {k0a, k1a, k2a, k3a, k4a, k5a} <= {k0, k1, v2, v3, v4, v5};

    always @ (posedge clk)
        out_1 <= {k0a, k1a, k2a, k3a, k4a, k5a};

    assign out_2 = {k2a, k3a, k4a, k5a};
endmodule

/* expand k0,k1,k4,k5 for every two clock cycles */
module expand_key_type_C_192 (clk, in, rcon, out_1, out_2);
    input              clk;
    input      [191:0] in;
    input      [7:0]   rcon;
    output reg [191:0] out_1;
    output     [127:0] out_2;
    wire       [31:0]  k0, k1, k2, k3, k4, k5,
                       v4, v5, v0, v1;
    reg        [31:0]  k0a, k1a, k2a, k3a, k4a, k5a;
    wire       [31:0]  k0b, k1b, k2b, k3b, k4b, k5b, k6a;

    assign {k0, k1, k2, k3, k4, k5} = in;
    
    assign v4 = k3 ^ k4;
    assign v5 = v4 ^ k5;
    assign v0 = {k0[31:24] ^ rcon, k0[23:0]};
    assign v1 = v0 ^ k1;

    always @ (posedge clk)
        {k0a, k1a, k2a, k3a, k4a, k5a} <= {v0, v1, k2, k3, v4, v5};

    S4
        S4_0 (clk, {v5[23:0], v5[31:24]}, k6a);

    assign k0b = k0a ^ k6a;
    assign k1b = k1a ^ k6a;
    assign {k2b, k3b, k4b, k5b} = {k2a, k3a, k4a, k5a};

    always @ (posedge clk)
        out_1 <= {k0b, k1b, k2b, k3b, k4b, k5b};

    assign out_2 = {k4b, k5b, k0b, k1b};
endmodule

/* expand k0,k1 for every two clock cycles */
module expand_key_type_D_192 (clk, in, rcon, out_1, out_2);
    input              clk;
    input      [191:0] in;
    input      [7:0]   rcon;
    output reg [191:0] out_1;
    output     [127:0] out_2;
    wire       [31:0]  k0, k1, k2, k3, k4, k5,
                       v0, v1;
    reg        [31:0]  k0a, k1a, k2a, k3a, k4a, k5a;
    wire       [31:0]  k0b, k1b, k2b, k3b, k4b, k5b, k6a;

    assign {k0, k1, k2, k3, k4, k5} = in;
    
    assign v0 = {k0[31:24] ^ rcon, k0[23:0]};
    assign v1 = v0 ^ k1;

    always @ (posedge clk)
        {k0a, k1a, k2a, k3a, k4a, k5a} <= {v0, v1, k2, k3, k4, k5};

    S4
        S4_0 (clk, {k5[23:0], k5[31:24]}, k6a);

    assign k0b = k0a ^ k6a;
    assign k1b = k1a ^ k6a;
    assign {k2b, k3b, k4b, k5b} = {k2a, k3a, k4a, k5a};

    always @ (posedge clk)
        out_1 <= {k0b, k1b, k2b, k3b, k4b, k5b};

    assign out_2 = {k4b, k5b, k0b, k1b};
endmodule
