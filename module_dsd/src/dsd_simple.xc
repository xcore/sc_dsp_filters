#include <stdio.h>

//extern int coeff_compressed[];
extern int dsd[];

#pragma unsafe arrays
int dsd_convert_xc(int coeff_compressed[], int Norig, int zero) {
    int sum = 0;
    int offset = 0;
    int N = Norig;
    do {
        N--;
        unsigned int d = dsd[(N+zero) & (Norig - 1)];
#pragma loop unroll
        for(unsigned int j = 0; j < 8; j ++) {
            int bits = (d >> 28) & 15;
            sum += coeff_compressed[offset + bits];
//        printf("%d  %d\n", coeff_compressed[offset + bits], bits);
            offset += 16;
            d <<= 4;
        }
    } while (N != 0);
    return sum;
}

