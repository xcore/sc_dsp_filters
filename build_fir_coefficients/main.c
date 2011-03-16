#include <stdio.h>
#include <math.h>

#define pi M_PI

typedef enum {HANN, HAMMING, GAUSSIAN, BLACKMAN} window;

// Window function from http://en.wikipedia.org/wiki/Window_function

double sqr(double x) {
    return x*x;
}

double windowValue(window w, int n, int N) {
    switch(w) {
    case HANN:    return 0.5 * (1 - cos (2 * n * pi / (N-1.0)));
    case HAMMING: return 0.54 - 0.46 * cos (2 * n * pi / (N-1.0));
    case GAUSSIAN: {
        double sigma = 0.4;
        return exp(-0.5*sqr( (n-(N-1.0)/2.0) / (sigma * (N-1.0)/2.0) ));
    }
    case BLACKMAN: {
        double alpha = 0.16;
        double a0 = (1-alpha)/2;
        double a1 = 0.5;
        double a2 = alpha/2;
        return a0 - a1*cos(2*pi*n/(N-1.0))+a2*cos(4*pi*n/(N-1.0));
    }
    }
    return 1.0;
}


double sinc(double x, double fc) {
    if (x == 0) {
        return 2*fc;
    } else {
        return sin(2*fc*pi*x)/(pi*x);
    }
}

double lp(double fc, window w, int n, int N) {
    double wi = windowValue(wi, n, N);
    double s = sinc(n-(N>>1), fc);
    return s*wi;
}

double hp(double fc, window w, int n, int N) {
    double l = lp(fc, w, n, N);
    if (n & 1) {
        return -l;
    } else {
        return l;
    }
}
// cool trick from http://www.dsprelated.com/groups/audiodsp/show/1036.php
// to convert low pass to high pass.




int main(void) {
    double samplingFrequency = 48000;
    double cutOff = 4800;
    double fc = cutOff / samplingFrequency;
    int i;
    int N = 21;
    double c[21];
    double sum = 0.0;

    for( i = 0; i < N; i++) {
        c[i] = hp(fc, HAMMING, i, N);
    }

    for(i = 0; i < N; i++) {
        sum += c[i];
        printf("%f\n", sum);
    }
}
