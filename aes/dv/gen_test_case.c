#include <stdio.h>
#include <stdlib.h>

typedef unsigned char byte;
typedef unsigned int word;

void encrypt_128_key_expand_inline_no_branch(word state[], word key[]);
void encrypt_192_key_expand_inline_no_branch(word state[], word key[]);
void encrypt_256_key_expand_inline_no_branch(word state[], word key[]);

word rand_word();
void rand_word_array(word w[], int bit_num);
void print_verilog_hex(word w[], int bit_num);

int main() {
    const int num_case = 5;
    int bit_num;
    int i;
    word state[4];
    word key[8];

    bit_num = 128;
    printf("AES-%d test cases:\n\n", bit_num);
    for(i=0; i<num_case; i++) {
        rand_word_array(state, 128);
        rand_word_array(key, bit_num);
        printf("plaintext: ");
        print_verilog_hex(state, 128);
        printf("\n");
        printf("key:       ");
        print_verilog_hex(key, bit_num);
        printf("\n");
        encrypt_128_key_expand_inline_no_branch(state, key);
        printf("ciphertext:");
        print_verilog_hex(state, 128);
        printf("\n\n");       
    }

    bit_num = 192;
    printf("AES-%d test cases:\n\n", bit_num);
    for(i=0; i<num_case; i++) {
        rand_word_array(state, 128);
        rand_word_array(key, bit_num);
        printf("plaintext: ");
        print_verilog_hex(state, 128);
        printf("\n");
        printf("key:       ");
        print_verilog_hex(key, bit_num);
        printf("\n");
        encrypt_192_key_expand_inline_no_branch(state, key);
        printf("ciphertext:");
        print_verilog_hex(state, 128);
        printf("\n\n");       
    }

    bit_num = 256;
    printf("AES-%d test cases:\n\n", bit_num);
    for(i=0; i<num_case; i++) {
        rand_word_array(state, 128);
        rand_word_array(key, bit_num);
        printf("plaintext: ");
        print_verilog_hex(state, 128);
        printf("\n");
        printf("key:       ");
        print_verilog_hex(key, bit_num);
        printf("\n");
        encrypt_256_key_expand_inline_no_branch(state, key);
        printf("ciphertext:");
        print_verilog_hex(state, 128);
        printf("\n\n");       
    }
    
    return 0;
}

word rand_word() {
    word w = 0;
    int i;
    for(i=0; i<4; i++) {
        word x = rand() & 255;
        w = (w << 8) | x;
    }
    return w;
}

void rand_word_array(word w[], int bit_num) {
    int word_num = bit_num / 32;
    int i;
    for(i=0; i<word_num; i++)
        w[i] = rand_word();
}

void print_verilog_hex(word w[], int bit_num) {
    int byte_num = bit_num / 8;
    int i;
    byte *b = (byte *)w;
    printf("%d'h", bit_num);
    for(i=0; i<byte_num; i++)
        printf("%02x", b[i]);
}
