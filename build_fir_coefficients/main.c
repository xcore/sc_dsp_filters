// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#define pi M_PI

typedef enum {HANN =1, HAMMING, GAUSSIAN, BLACKMAN} window;

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

/*
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
    for(i = 0; i < N; i++) {
        sum += c[i];
        printf("%f\n", sum);
    }
    return 0;
}
*/

// check http://www.dspguide.com/ch17/1.htm For arbitrary response FIR.





void usage() {
    fprintf(stderr,
            " -low freq            Lowpass filter, with given corner freq\n"
            " -high freq           Highpass filter, with given corner freq\n"
            " -bp freql freqh      Bandpass filter, with given frequencies\n"
            " -bs freql freqh      Bandstop filter, with given frequencies\n\n"
            " -gaussian            Gaussian window\n"
            " -blackman            Blackman window\n"
            " -hamming             Hamming window (default)\n"
            " -hann                Hann window\n\n"
            " -n taps              Number of taps - should be odd\n"
            " -fs freq             Sample frequency, default 48000\n\n"
            " -h includeFileName   name of include file, default coeffs.h\n"
            " -xc sourceFileName   name of source file, default coeffs.xc\n"
            " -csv csvFileName     name of csv file, default response.csv\n\n"
            "One of -low, -high, -bp, or -bs must be specified\n"
            "Outputs are\n"
            " an include file for specific filter banks\n"
            " a source code file that initialises the coefficients table\n"
            " a CSV file that contains the response curves\n"
        );
    exit(0);
}

FILE *fopen_save(char *x) {
    FILE *fd = fopen(x, "w");
    if (fd == NULL) {
        fprintf(stderr, "Cannot open %s for writing\n", x);
        exit(1);
    }
    return fd;
}

enum {LOW = 1, HIGH, BP, BS};

int main(int argc, char *argv[]) {
    int i;
    double fs = 48000;
    char *sourceFile = "coeffs.xc";
    char *responseCurve = "response.csv";
    double *c = NULL;
    int win = HAMMING;
    int type = 0;
    int N = 0;

    FILE *fdXC, *fdCSV;
    double freq = 0, freqh = 0;

    if (argc < 5) usage();
    for( i = 1; i<argc; i++) {
        if (strcmp(argv[i], "-low") == 0) {
            type = LOW;
            freq = atof(argv[++i]);
        } else if (strcmp(argv[i], "-high") == 0) {
            type = HIGH;
            freq = atof(argv[++i]);
        } else if (strcmp(argv[i], "-bp") == 0) {
            type = BP;
            freq = atof(argv[++i]);
            freqh = atof(argv[++i]);
        } else if (strcmp(argv[i], "-bs") == 0) {
            type = BS;
            freq = atof(argv[++i]);
            freqh = atof(argv[++i]);
        } else if (strcmp(argv[i], "-fs") == 0) {
            fs = atof(argv[++i]);
        } else if (strcmp(argv[i], "-gaussian") == 0) {
            win = GAUSSIAN;
        } else if (strcmp(argv[i], "-hamming") == 0) {
            win = HAMMING;
        } else if (strcmp(argv[i], "-hann") == 0) {
            win = HANN;
        } else if (strcmp(argv[i], "-blackman") == 0) {
            win = BLACKMAN;
        } else if (strcmp(argv[i], "-n") == 0) {
            N = atoi(argv[++i]);
            c = calloc(sizeof(double), N);
        } else if (strcmp(argv[i], "-xc") == 0) {
            sourceFile = argv[++i];
        } else if (strcmp(argv[i], "-csv") == 0) {
            responseCurve = argv[++i];
        } else {
            usage();
        }

    }
    if (c == NULL || type == 0 || (N&1) == 0) {
        usage();
    }
    fdXC = fopen_save(sourceFile);
    fdCSV = fopen_save(responseCurve);

    freq /= fs;
    freqh /= fs;
    for( i = 0; i < N; i++) {
        switch(type) {
        case LOW:
            c[i] = lp(freq, win, i, N);
            break;
        case HIGH:
            c[i] = hp(freqh, win, i, N);
            break;
        case BP:
            c[i] = bp(freq, freqh, win, i, N);
            break;
        case BS:
            c[i] = bs(freq, freqh, win, i, N);
            break;
        }
    }

    fprintf(fdXC,
            "//Generated code - do not edit.\n\n"
            "#define TAPS %d\n"
            "int coeff[TAPS] = {\n", N);
    for( i = 0; i < N; i++) {
        fprintf(fdXC, " %d, // %10f\n", (int) floor(c[i] * (1<<24) + 0.5), c[i]); 
    }
    fprintf(fdXC, "};\n");


// freq response, from http://www.dspguru.com/dsp/faqs/fir/properties

    {
        double omega;
        int i;
        double factor = sqrt(sqrt(sqrt(sqrt(sqrt(2.0)))));
        fprintf( fdCSV, "Frequency,Magnitude,dB\n");
        for(omega = 50; omega < fs/2; omega = omega * factor) {
            double sumr = 0;
            double sumi = 0;
            double mag;
            
            for(i = 0; i < N; i++) {
                double o = omega/fs * 2 * pi;
                sumr += c[i] * cos(i*o);
                sumi += c[i] * sin(i*o);
            }
            mag = sqrt(sumi*sumi + sumr*sumr);
            fprintf( fdCSV, "%.0f,%.8f,%.3f\n", omega, mag, 20*log10(mag));
        }
    }

    return 0;
}
