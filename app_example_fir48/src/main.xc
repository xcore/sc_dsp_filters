#include <stdio.h>
#include <stdlib.h>
#include <fir12.h>
#include <fir12_par.h>

#define N 48

extern void fflushit(void);

/* Function that produces samples and send them to the FIR. It also times
 * the FIR and sends the sample to a verification process to check that the
 * answers are as expected. It prints the last few times after 400
 * iterations.
 */
void produce(streaming chanend cin, streaming chanend verif) {
    long long result, result2;
    timer tt;
    int x, y;
    int times[8];
    for(int j = 0; j < 400; j++) {
        int sample = j^55;
        tt :> x;             // Take time before
        cin <: sample;       // Send a sample
        cin :> result;       // Get the result
        tt :> y;             // Take a time stamp
        verif <: sample;      // Now send sample to verification FIR
        verif :> result2;     // And get result from verification FIR
        times[j&7] = y-x;
        if (result != result2) {
            printf("Error, iteration %d values %lld correct is %lld\n", j, result, result2);
        } else {
            printf("Ok %d %lld\r", j, result);
            fflushit();
        }
    }
    for(int j = 0; j < 8; j++) {
        printf("%d\n", times[j]);
    }
    exit(0);
}

/* Function that computes a FIR - for verifying that the answers are correct
 * Not efficient - just correct.
 */
void localFir(const int coeffs[N], streaming chanend cin) {
    int in_data[N];
    for(int i = 0; i < N; i++) {
        in_data[i] = 0;
    }
    while(1) {
        long long sum = 0;
        cin :> in_data[0];
        for(int i = 0; i < N; i++) {
            sum += (long long) in_data[i] * (long long) coeffs[i];
        }
        for(int i = N-2; i >=0; i--) {
            in_data[i+1] = in_data[i];
        }
        cin <: sum;
    }
}

int main(void) {
    int coeffs[N];
    int coeffs2[N];
    int data0[N/1+12]; // Big enough to test 1, 2, 3, 4
    int data1[N/2+12]; // Big enough to test 2, 3, 4
    int data2[N/3+12]; // Big enough to test 3, 4
    int data3[N/4+12]; // Big enough to test 4
    streaming chan cin, verif;

    // Make up some coefficients
    for(int i = 0; i < N; i++) {
        int coeff = (i+1)^0x15;
        coeffs[i]  = coeff;
        coeffs2[i] = coeff;
    }
    par {
        fir_par4_48(coeffs, N, cin, data0, data1, data2, data3);
//        fir_par3_36(coeffs, N, cin, data0, data1, data2);
//        fir_par2_24(coeffs, N, cin, data0, data1);
//        fir_par1_12(coeffs, N, cin, data0);
        produce(cin, verif);
        localFir(coeffs2, verif);
    }
    return 0;
}
