#include <stdio.h>
#include <fir12.h>
#include <fir48_4.h>

#define N (768*1)

void produce(streaming chanend cin) {
    long long result;
    timer tt;
    int x, y;
    int times[500];
    for(int j = 0; j < 50; j++) {
        tt :> x;
        cin <: j;
        cin :> result;
        tt :> y;
        times[j] = y-x;
    }
    for(int j = 0; j < 50; j++) {
        printf("%d\n", times[j]);
    }
}


int main(void) {
    int coeffs[N];
    streaming chan cin;

    // Make up some coefficients
    for(int i = 0; i < N; i++) {
        coeffs[i] = i+1;
    }
    par {
        fir48_4(coeffs, N, cin);
        produce(cin);
    }
    return 0;
}
