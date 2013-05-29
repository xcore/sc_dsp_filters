#include <fir48_4.h>
#include <fir12.h>
#include <stdio.h>

#define MAX_N (192*2)

#pragma unsafe arrays
void fir12_1(const int coefficients[], int offset, int N, streaming chanend cin, streaming chanend cout) {
    int data[MAX_N+12], dat;
    int w = 0;
    long long result, res;
    timer tt; int x, y;
    for(int i = 0; i < N+12; i++) {
        data[i] = 0;
    }

    while(1) {
        cout <: data[w];
        cin :> dat;
        data[w] = dat;
        if (w < 12) {
            data[N+w] = dat;
        }
        result = fir12coffset(coefficients, data, w, N, offset);
        cout :> res;
        cin <: result+res;
        w++;
        if (w == N) {
            w = 0;
        }
    }
}

#pragma unsafe arrays
void fir12_e(const int coefficients[], int offset, int N, streaming chanend cin) {
    int data[MAX_N+12], dat;
    int w = 0;
    for(int i = 0; i < N+12; i++) {
        data[i] = 0;
    }
    while(1) {
        cin :> dat;
        data[w] = dat;
        if (w < 12) {
            data[N+w] = dat;
        }
        cin <: fir12coffset(coefficients, data, w, N, offset);
        w++;
        if (w == N) {
            w = 0;
        }
    }
}

void fir48_4(int coefficients[], int N, streaming chanend cin) {
    streaming chan a, b, c;
    par {
        fir12_1(coefficients, 0*N/4, N/4, cin, a);
        fir12_1(coefficients, 1*N/4, N/4, a, b);
        fir12_1(coefficients, 2*N/4, N/4, b, c);
        fir12_e(coefficients, 3*N/4, N/4, c);
    }
}

void fir24_2(int coefficients[], int N, streaming chanend cin) {
    streaming chan a;
    par {
        fir12_1(coefficients, 0*N/2, N/2, cin, a);
        fir12_e(coefficients, 1*N/2, N/2, a);
    }
}
