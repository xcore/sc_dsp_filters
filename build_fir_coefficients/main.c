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
    double wi = windowValue(w, n, N);
    double s = sinc(n-(N>>1), fc);
    if (N * fc < 4) {
        printf("Expected taps to be at least %d\n", ((int) (4/fc))|1);
    }
    return s*wi;
}

// even cooler trick from http://mpastell.com/2010/01/18/fir-with-scipy/
// to convert low pass to high pass.

double hp(double fc, window w, int n, int N) {
    double l = lp(fc, w, n, N);
    if (n != (N>>1)) {
        return -l;
    } else {
        return 1-l;
    }
}

/* Band stop, from same website */

double bs(double fcl, double fch, window w, int n, int N) {
    double l = lp(fcl, w, n, N);
    double h = hp(fch, w, n, N);
    return l+h;
}

/* Band pass, from same website */

double bp(double fcl, double fch, window w, int n, int N) {
    double b = bs(fcl, fch, w, n, N);
    if (n != (N>>1)) {
        return -b;
    } else {
        return 1-b;
    }
}

// freq response, from http://www.dspguru.com/dsp/faqs/fir/properties

void freq(int N, double h[], double f) {
    double omega;
    int i;
    double factor = sqrt(sqrt(sqrt(sqrt(sqrt(2.0)))));
    for(omega = 50; omega < f/2; omega = omega * factor) {
        double sumr = 0;
        double sumi = 0;
        double mag;

        for(i = 0; i < N; i++) {
            double o = omega/f * 2 * pi;
            sumr += h[i] * cos(i*o);
            sumi += h[i] * sin(i*o);
        }
        mag = sqrt(sumi*sumi + sumr*sumr);
        printf("%8.0f    %f   %8.4f\n", omega, mag, 20*log10(mag));
    }
}

int main(void) {
    double samplingFrequency = 48000;
    double cutOffl =  800;
    double fcl = cutOffl / samplingFrequency;
    double cutOffh = 6400;
    double fch = cutOffh / samplingFrequency;
    int i;
    int N = 231;
    double c[231];

    for( i = 0; i < N; i++) {
        c[i] = bp(fcl, fch, HAMMING, i, N);
//        c[i] = hp(fch, HAMMING, i, N);
    }

    freq(N, c, samplingFrequency);
/*
    for(i = 0; i < N; i++) {
        sum += c[i];
        printf("%f\n", sum);
    }
*/
    return 0;
}
