#include <stdio.h>
#include <fir12.h>

#define N 120


int main(void) {
    int coeffs[N];
    int data[N+FIR_MODULO];
    timer tt;
    int x, y, w, s = 0, t = 0;
    long long z;

    // Make up some coefficients
    for(int i = 0; i < N; i++) {
        s += (i+1)*i;
        coeffs[i] = i+1;
        t += i+1;
    }
    // Make up some data
    for(int i = 0; i < N; i++) {
        data[i] = i;
        if (i < FIR_MODULO) {
            data[i+N] = i;
        }
    }
    w = 0;
    // compute fir 140 times, over a sliding window.
    for(int j = 0; j < 140; j++) {
        tt :> x;
        z = fir12(coeffs, data, w, N);
        tt :> y;
        printf("%lld  %d: %lld\n", s+j*t-z, y-x, z);
        data[w] = j+N;
        if (w < FIR_MODULO) {
            data[w+N] = j+N;
        }
        w++;
        if (w >= N) {
            w = 0;
        }
    }
    return 0;
}
