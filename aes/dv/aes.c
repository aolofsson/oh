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

#include "sbox.h"

#ifndef LOCAL
#define LOCAL
#endif

#define byte unsigned char
typedef unsigned int word;

#define sub_byte(w) {       \
    byte *b = (byte *)&w;   \
    b[0] = table_0[b[0]*4]; \
    b[1] = table_0[b[1]*4]; \
    b[2] = table_0[b[2]*4]; \
    b[3] = table_0[b[3]*4]; \
}
#define rot_up_8(x)   x = (x << 8) | (x >> 24)
#define rot_16(x)     x = (x << 16) | (x >> 16)
#define rot_down_8(x) x = (x >> 8) | (x << 24)
#define table_lookup { \
    p0 = t0[b[0]];     \
    p1 = t0[b[1]];     \
    p2 = t0[b[2]];     \
    p3 = t0[b[3]];     \
}
#define final_mask if(is_final_round) { \
    p0 &= 0xFF;  \
    p1 &= 0xFF00; \
    rot_16(p2);   \
    p2 &= 0xFF0000; \
    rot_down_8(p3); \
    p3 &= 0xFF000000; \
} else { \
    rot_up_8(p0);      \
    rot_16(p1);        \
    rot_down_8(p2);    \
}
#define rot {       \
    rot_up_8(p0);   \
    rot_16(p1);     \
    rot_down_8(p2); \
}

void encrypt_128_key_expand_inline(word state[], word key[]) {
    int nr = 10;
    int i;
    word k0 = key[0], k1 = key[1], k2 = key[2], k3 = key[3];
    state[0] ^= k0;
    state[1] ^= k1;
    state[2] ^= k2;
    state[3] ^= k3;
    word *t0 = (word *)table_0;
    word y, p0, p1, p2, p3;
    byte *b = (byte *)&y;
    byte rcon = 1;

    for(i=1; i<=nr; i++) {
        word temp = k3;
        rot_down_8(temp);
        sub_byte(temp);
        temp ^= rcon;
        int j = (char)rcon;
        j <<= 1;
        j ^= (j >> 8) & 0x1B; // if (rcon&0x80 != 0) then (j ^= 0x1B)
        rcon = (byte)j;
        k0 ^= temp;
        k1 ^= k0;
        k2 ^= k1;
        k3 ^= k2;

        word z0 = k0, z1 = k1, z2 = k2, z3 = k3;
        int is_final_round = i == nr;

        y = state[0];
        table_lookup;
        final_mask;
        z0 ^= p0, z3 ^= p1, z2 ^= p2, z1 ^= p3;

        y = state[1];
        table_lookup;
        final_mask;
        z1 ^= p0, z0 ^= p1, z3 ^= p2, z2 ^= p3;

        y = state[2];
        table_lookup;
        final_mask;
        z2 ^= p0, z1 ^= p1, z0 ^= p2, z3 ^= p3;

        y = state[3];
        table_lookup;
        final_mask;

        state[0] = z0 ^ p3;
        state[1] = z1 ^ p2;
        state[2] = z2 ^ p1;
        state[3] = z3 ^ p0;
    }
}

void encrypt_128_key_expand_inline_no_branch(word state[], word key[]) {
    int nr = 10;
    int i;
    word k0 = key[0], k1 = key[1], k2 = key[2], k3 = key[3];
    state[0] ^= k0;
    state[1] ^= k1;
    state[2] ^= k2;
    state[3] ^= k3;
    word *t0 = (word *)table_0;
    word p0, p1, p2, p3;
    byte *b;
    byte rcon = 1;

    for(i=1; i<nr; i++) {
        word temp = k3;
        rot_down_8(temp);
        sub_byte(temp);
        temp ^= rcon;
        int j = (char)rcon;
        j <<= 1;
        j ^= (j >> 8) & 0x1B; // if (rcon&0x80 != 0) then (j ^= 0x1B)
        rcon = (byte)j;
        k0 ^= temp;
        k1 ^= k0;
        k2 ^= k1;
        k3 ^= k2;
        word z0 = k0, z1 = k1, z2 = k2, z3 = k3;
        b = (byte *)state; table_lookup; rot;
        z0 ^= p0, z3 ^= p1, z2 ^= p2, z1 ^= p3;
        b += 4; table_lookup; rot;
        z1 ^= p0, z0 ^= p1, z3 ^= p2, z2 ^= p3;
        b += 4; table_lookup; rot;
        z2 ^= p0, z1 ^= p1, z0 ^= p2, z3 ^= p3;
        b += 4; table_lookup; rot;
        state[0] = z0 ^ p3;
        state[1] = z1 ^ p2;
        state[2] = z2 ^ p1;
        state[3] = z3 ^ p0;
    }
    word temp = k3;
    rot_down_8(temp);
    sub_byte(temp);
    temp ^= rcon;
    k0 ^= temp;
    k1 ^= k0;
    k2 ^= k1;
    k3 ^= k2;
    byte *a = (byte *)state, *t = table_0;
    b = (byte *)&k0;
    b[0] ^= t[a[0]*4], b[1] ^= t[a[5]*4], b[2] ^= t[a[10]*4], b[3] ^= t[a[15]*4];
    b = (byte *)&k1;
    b[0] ^= t[a[4]*4], b[1] ^= t[a[9]*4], b[2] ^= t[a[14]*4], b[3] ^= t[a[3]*4];
    b = (byte *)&k2;
    b[0] ^= t[a[8]*4], b[1] ^= t[a[13]*4], b[2] ^= t[a[2]*4], b[3] ^= t[a[7]*4];
    b = (byte *)&k3;
    b[0] ^= t[a[12]*4], b[1] ^= t[a[1]*4], b[2] ^= t[a[6]*4], b[3] ^= t[a[11]*4];
    state[0] = k0;
    state[1] = k1;
    state[2] = k2;
    state[3] = k3;
}

void encrypt_192_key_expand_inline_no_branch(word state[], word key[]) {
    int i = 1, j;
    word *t0 = (word *)table_0;
    word k0 = key[0], k1 = key[1], k2 = key[2], k3 = key[3], k4 = key[4], k5 = key[5];
    word p0, p1, p2, p3, z0, z1, z2, z3, temp;
    byte *a = (byte *)state, *b, *t = table_0;
    byte rcon = 1;

    state[0] ^= k0; state[1] ^= k1; state[2] ^= k2; state[3] ^= k3;

    goto a;

    for(; i<=3; i++) { // round 1 ~ round 9
        k4 ^= k3; k5 ^= k4;
a:      temp = k5;
        rot_down_8(temp);
        sub_byte(temp);
        temp ^= rcon;
        j = (int)((char)rcon) << 1;
        rcon = (byte) (((j >> 8) & 0x1B) ^ j); // if (rcon&0x80 != 0) then (j ^= 0x1B)
        k0 ^= temp; k1 ^= k0;

        z0 = k4, z1 = k5, z2 = k0, z3 = k1;
        b = (byte *)state; table_lookup; rot;
        z0 ^= p0, z3 ^= p1, z2 ^= p2, z1 ^= p3;
        b += 4; table_lookup; rot;
        z1 ^= p0, z0 ^= p1, z3 ^= p2, z2 ^= p3;
        b += 4; table_lookup; rot;
        z2 ^= p0, z1 ^= p1, z0 ^= p2, z3 ^= p3;
        b += 4; table_lookup; rot;
        state[0] = z0 ^ p3;
        state[1] = z1 ^ p2;
        state[2] = z2 ^ p1;
        state[3] = z3 ^ p0;

        k2 ^= k1; k3 ^= k2; k4 ^= k3; k5 ^= k4;

        z0 = k2, z1 = k3, z2 = k4, z3 = k5;
        b = (byte *)state; table_lookup; rot;
        z0 ^= p0, z3 ^= p1, z2 ^= p2, z1 ^= p3;
        b += 4; table_lookup; rot;
        z1 ^= p0, z0 ^= p1, z3 ^= p2, z2 ^= p3;
        b += 4; table_lookup; rot;
        z2 ^= p0, z1 ^= p1, z0 ^= p2, z3 ^= p3;
        b += 4; table_lookup; rot;
        state[0] = z0 ^ p3;
        state[1] = z1 ^ p2;
        state[2] = z2 ^ p1;
        state[3] = z3 ^ p0;

        temp = k5;
        rot_down_8(temp);
        sub_byte(temp);
        temp ^= rcon;
        j = (int)((char)rcon) << 1;
        rcon = (byte) (((j >> 8) & 0x1B) ^ j); // if (rcon&0x80 != 0) then (j ^= 0x1B)
        k0 ^= temp; k1 ^= k0; k2 ^= k1; k3 ^= k2;

        z0 = k0, z1 = k1, z2 = k2, z3 = k3;
        b = (byte *)state; table_lookup; rot;
        z0 ^= p0, z3 ^= p1, z2 ^= p2, z1 ^= p3;
        b += 4; table_lookup; rot;
        z1 ^= p0, z0 ^= p1, z3 ^= p2, z2 ^= p3;
        b += 4; table_lookup; rot;
        z2 ^= p0, z1 ^= p1, z0 ^= p2, z3 ^= p3;
        b += 4; table_lookup; rot;
        state[0] = z0 ^ p3;
        state[1] = z1 ^ p2;
        state[2] = z2 ^ p1;
        state[3] = z3 ^ p0;
    }
    // round 10 ~ 12

    k4 ^= k3; k5 ^= k4;
    temp = k5;
    rot_down_8(temp);
    sub_byte(temp);
    temp ^= rcon;
    j = (int)((char)rcon) << 1;
    rcon = (byte) (((j >> 8) & 0x1B) ^ j); // if (rcon&0x80 != 0) then (j ^= 0x1B)
    k0 ^= temp; k1 ^= k0;

    z0 = k4, z1 = k5, z2 = k0, z3 = k1;
    b = (byte *)state; table_lookup; rot;
    z0 ^= p0, z3 ^= p1, z2 ^= p2, z1 ^= p3;
    b += 4; table_lookup; rot;
    z1 ^= p0, z0 ^= p1, z3 ^= p2, z2 ^= p3;
    b += 4; table_lookup; rot;
    z2 ^= p0, z1 ^= p1, z0 ^= p2, z3 ^= p3;
    b += 4; table_lookup; rot;
    state[0] = z0 ^ p3;
    state[1] = z1 ^ p2;
    state[2] = z2 ^ p1;
    state[3] = z3 ^ p0;

    k2 ^= k1; k3 ^= k2; k4 ^= k3; k5 ^= k4;

    z0 = k2, z1 = k3, z2 = k4, z3 = k5;
    b = (byte *)state; table_lookup; rot;
    z0 ^= p0, z3 ^= p1, z2 ^= p2, z1 ^= p3;
    b += 4; table_lookup; rot;
    z1 ^= p0, z0 ^= p1, z3 ^= p2, z2 ^= p3;
    b += 4; table_lookup; rot;
    z2 ^= p0, z1 ^= p1, z0 ^= p2, z3 ^= p3;
    b += 4; table_lookup; rot;
    state[0] = z0 ^ p3;
    state[1] = z1 ^ p2;
    state[2] = z2 ^ p1;
    state[3] = z3 ^ p0;

    temp = k5;
    rot_down_8(temp);
    sub_byte(temp);
    temp ^= rcon;
    k0 ^= temp; k1 ^= k0; k2 ^= k1; k3 ^= k2;
    b = (byte *)&k0; b[0] ^= t[a[0]*4], b[1] ^= t[a[5]*4], b[2] ^= t[a[10]*4], b[3] ^= t[a[15]*4];
    b = (byte *)&k1; b[0] ^= t[a[4]*4], b[1] ^= t[a[9]*4], b[2] ^= t[a[14]*4], b[3] ^= t[a[3]*4];
    b = (byte *)&k2; b[0] ^= t[a[8]*4], b[1] ^= t[a[13]*4], b[2] ^= t[a[2]*4], b[3] ^= t[a[7]*4];
    b = (byte *)&k3; b[0] ^= t[a[12]*4], b[1] ^= t[a[1]*4], b[2] ^= t[a[6]*4], b[3] ^= t[a[11]*4];
    state[0] = k0;
    state[1] = k1;
    state[2] = k2;
    state[3] = k3;
}

void encrypt_256_key_expand_inline_no_branch(word state[], word key[]) {
    int i=1, j;
    word *t0 = (word *)table_0;
    word k0 = key[0], k1 = key[1], k2 = key[2], k3 = key[3],
         k4 = key[4], k5 = key[5], k6 = key[6], k7 = key[7];
    word p0, p1, p2, p3, z0, z1, z2, z3, temp;
    byte *a = (byte *)state, *b, *t = table_0;
    byte rcon = 1;

    state[0] ^= k0; state[1] ^= k1; state[2] ^= k2; state[3] ^= k3;

    goto a;

    for(; i<=6; i++) { // round 1 ~ round 12
        temp = k3; sub_byte(temp); k4 ^= temp;
        k5 ^= k4; k6 ^= k5; k7 ^= k6;

a:      z0 = k4, z1 = k5, z2 = k6, z3 = k7;
        b = (byte *)state; table_lookup; rot;
        z0 ^= p0, z3 ^= p1, z2 ^= p2, z1 ^= p3;
        b += 4; table_lookup; rot;
        z1 ^= p0, z0 ^= p1, z3 ^= p2, z2 ^= p3;
        b += 4; table_lookup; rot;
        z2 ^= p0, z1 ^= p1, z0 ^= p2, z3 ^= p3;
        b += 4; table_lookup; rot;
        state[0] = z0 ^ p3;
        state[1] = z1 ^ p2;
        state[2] = z2 ^ p1;
        state[3] = z3 ^ p0;

        temp = k7;
        rot_down_8(temp);
        sub_byte(temp);
        temp ^= rcon;
        j = (int)((char)rcon) << 1;
        rcon = (byte) (((j >> 8) & 0x1B) ^ j); // if (rcon&0x80 != 0) then (j ^= 0x1B)
        k0 ^= temp; k1 ^= k0; k2 ^= k1; k3 ^= k2;

        z0 = k0, z1 = k1, z2 = k2, z3 = k3;
        b = (byte *)state; table_lookup; rot;
        z0 ^= p0, z3 ^= p1, z2 ^= p2, z1 ^= p3;
        b += 4; table_lookup; rot;
        z1 ^= p0, z0 ^= p1, z3 ^= p2, z2 ^= p3;
        b += 4; table_lookup; rot;
        z2 ^= p0, z1 ^= p1, z0 ^= p2, z3 ^= p3;
        b += 4; table_lookup; rot;
        state[0] = z0 ^ p3;
        state[1] = z1 ^ p2;
        state[2] = z2 ^ p1;
        state[3] = z3 ^ p0;
    }
    // round 13 ~ 14

    temp = k3; sub_byte(temp); k4 ^= temp;
    k5 ^= k4; k6 ^= k5; k7 ^= k6;

    z0 = k4, z1 = k5, z2 = k6, z3 = k7;
    b = (byte *)state; table_lookup; rot;
    z0 ^= p0, z3 ^= p1, z2 ^= p2, z1 ^= p3;
    b += 4; table_lookup; rot;
    z1 ^= p0, z0 ^= p1, z3 ^= p2, z2 ^= p3;
    b += 4; table_lookup; rot;
    z2 ^= p0, z1 ^= p1, z0 ^= p2, z3 ^= p3;
    b += 4; table_lookup; rot;
    state[0] = z0 ^ p3;
    state[1] = z1 ^ p2;
    state[2] = z2 ^ p1;
    state[3] = z3 ^ p0;

    temp = k7;
    rot_down_8(temp);
    sub_byte(temp);
    temp ^= rcon;
    k0 ^= temp; k1 ^= k0; k2 ^= k1; k3 ^= k2;

    b = (byte *)&k0; b[0] ^= t[a[0]*4], b[1] ^= t[a[5]*4], b[2] ^= t[a[10]*4], b[3] ^= t[a[15]*4];
    b = (byte *)&k1; b[0] ^= t[a[4]*4], b[1] ^= t[a[9]*4], b[2] ^= t[a[14]*4], b[3] ^= t[a[3]*4];
    b = (byte *)&k2; b[0] ^= t[a[8]*4], b[1] ^= t[a[13]*4], b[2] ^= t[a[2]*4], b[3] ^= t[a[7]*4];
    b = (byte *)&k3; b[0] ^= t[a[12]*4], b[1] ^= t[a[1]*4], b[2] ^= t[a[6]*4], b[3] ^= t[a[11]*4];
    state[0] = k0;
    state[1] = k1;
    state[2] = k2;
    state[3] = k3;
}
