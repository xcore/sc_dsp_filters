// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define pi 3.1415926536
int FRACTIONALBITS = 24;

#define hzCnt  42
#define maxDbs 41

float gain[maxDbs][hzCnt];
float igain[maxDbs][hzCnt];
float freqs[hzCnt];
int thedb;

FILE *fdH, *fdXC, *fdCSV;

int errorValue = 0;

int R(double x) {
    if (x >= (1<<(31-FRACTIONALBITS)) ||
        x < -(1<<(31-FRACTIONALBITS))) {
        fprintf(stderr, "Overflow: constant %f too large, maximum with %d fractional bits is %d\n",
                x, FRACTIONALBITS, 1<<(31-FRACTIONALBITS));
        errorValue++;
    }
    return floor((1<<FRACTIONALBITS) * x + 0.5);
}

double Fs = 48000.0;

double sqr(double x) {
    return x*x;
}

void printout(double a0, double a1, double a2, double b0, double b1, double b2) {
    int cnt = 0;

    double ra1 = R(a1/a0) / (double) (1<<FRACTIONALBITS);
    double ra2 = R(a2/a0) / (double) (1<<FRACTIONALBITS);
    double rb0 = R(b0/a0) / (double) (1<<FRACTIONALBITS);
    double rb1 = R(b1/a0) / (double) (1<<FRACTIONALBITS);
    double rb2 = R(b2/a0) / (double) (1<<FRACTIONALBITS);
    double ra0 = 1;

    for(cnt = 0; cnt < hzCnt; cnt++) {
        double w = 2 * pi * freqs[cnt] / Fs;
        double phi = sin(w/2);
        phi = phi * phi;
        igain[thedb][cnt] +=
            10*log10( sqr(b0+b1+b2) - 4*(b0*b1 + 4*b0*b2 + b1*b2)*phi + 16*b0*b2*sqr(phi) )
            -10*log10( sqr(a0+a1+a2) - 4*(a0*a1 + 4*a0*a2 + a1*a2)*phi + 16*a0*a2*sqr(phi) );
        gain[thedb][cnt] +=
            10*log10( sqr(rb0+rb1+rb2) - 4*(rb0*rb1 + 4*rb0*rb2 + rb1*rb2)*phi + 16*rb0*rb2*sqr(phi) )
            -10*log10( sqr(ra0+ra1+ra2) - 4*(ra0*ra1 + 4*ra0*ra2 + ra1*ra2)*phi + 16*ra0*ra2*sqr(phi) );
    }

    fprintf(fdXC, "    {%10d, %10d, %10d, %10d, %10d},\n",
            R(b0/a0), R(b1/a0), R(b2/a0),
            -R(a1/a0), -R(a2/a0)
        );
}

void peakingEQ(double f0, double dbGain, double BW) {
    double A = pow(10.0, dbGain / 40.0);
    double w0 = 2 * pi * f0  /Fs;
    double cosw0 = cos(w0);
    double sinw0 = sin(w0);
    double alpha = sinw0 * sinh(log(2.0)/2.0 * BW * w0/sinw0);
    double b0 = 1 + alpha * A;
    double b1 = -2 * cosw0;
    double b2 = 1 - alpha * A;
    double a0 = 1 + alpha / A;
    double a1 = -2 * cosw0;
    double a2 = 1 - alpha / A;
    printout( a0, a1, a2, b0, b1, b2);
}

void lowShelf(double fin, double dbGain) {
    double f0 = fin;
    double A = pow(10.0, dbGain / 40.0);
    double w0 = 2 * pi * f0  /Fs;
    double cosw0 = cos(w0);
    double sqrtA = sqrt(A);
    double S = 1;
    double alpha = sin(w0)/2*sqrt((A+1/A)*(1/S-1)+2);
    double b0 =   A*((A+1)-(A-1)*cosw0 + 2*sqrtA*alpha);
    double b1 = 2*A*((A-1)-(A+1)*cosw0                );
    double b2 =   A*((A+1)-(A-1)*cosw0 - 2*sqrtA*alpha);
    double a0 =     ((A+1)+(A-1)*cosw0 + 2*sqrtA*alpha);
    double a1 =-2*  ((A-1)+(A+1)*cosw0                );
    double a2 =     ((A+1)+(A-1)*cosw0 - 2*sqrtA*alpha);
    printout( a0, a1, a2, b0, b1, b2);
}

void highShelf(double f0, double dbGain) {
    double A = pow(10.0, dbGain / 40.0);
    double w0 = 2 * pi * f0  /Fs;
    double cosw0 = cos(w0);
    double sqrtA = sqrt(A);
    double S = 1;
    double alpha = sin(w0)/2*sqrt((A+1/A)*(1/S-1)+2);
    double b0 =   A*((A+1)+(A-1)*cosw0 + 2*sqrtA*alpha);
    double b1 =-2*A*((A-1)+(A+1)*cosw0                );
    double b2 =   A*((A+1)+(A-1)*cosw0 - 2*sqrtA*alpha);
    double a0 =     ((A+1)-(A-1)*cosw0 + 2*sqrtA*alpha);
    double a1 = 2*  ((A-1)-(A+1)*cosw0                );
    double a2 =     ((A+1)-(A-1)*cosw0 - 2*sqrtA*alpha);
    printout( a0, a1, a2, b0, b1, b2);
}

void usage() {
    fprintf(stderr,
            " -low freq            Low shelf filter, with given corner freq\n"
            " -high freq           High shelf filter, with given corner freq\n"
            " -peaking freq bw     PeakingEQ filter, with given corner freq and bw in octaves\n\n"
            " -bits fractionalBits number of fractional bits, default 24\n"
            " -min minDb           minimal dB value, default -20\n"
            " -max maxDb           maximal dB value, default +20\n"
            " -step dbStep         Dbs between each step, default 1\n"
            " -fs freq             Sample frequency, default 48000\n\n"
            " -h includeFileName   name of include file, default coeffs.h\n"
            " -xc sourceFileName   name of source file, default coeffs.xc\n"
            " -csv csvFileName     name of csv file, default response.csv\n\n"
            "eg:  -min -20 -max 20 -step 4 -low 250 -high 4000\n"
            "or   -min -20 -max 20 -low 400 -peaking 800 1 -peaking 1600 1 -high 3200\n"
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

enum {LOW, HIGH, PEAKING};

char *nextArg(char **string, int skip) {
    char *retval;
    (*string) += skip;
    while (**string == ' ') {
        (*string)++;
    }
    retval = *string;
    while (**string != ' ' && **string) {
        (*string)++;
    }
    return retval;
}

int main(void) {
    double f;
    int dbcnt;
    int filterCnt = 0;
    double mindb=-20, maxdb=20, stepdb=1;
    int i, j;
    char *includeFile = "coeffs.h";
    char *sourceFile = "coeffs.xc";
    char *responseCurve = "response.csv";
    char *argString = FILTER;

#ifdef INCLUDEFILE
    includeFile = INCLUDEFILE;
#endif

#ifdef XCFILE
    sourceFile = XCFILE;
#endif

#ifdef CSVFILE
    responseCurve = CSVFILE;
#endif

    struct {
        double freq, bw;
        int type;
    } filters[40];

    while (*argString) {
        printf("%s ... %d\n", argString, filterCnt);
        if (*argString == ' ') {
            argString++;
            continue;
        }
        if (strncmp(argString, "-low", 4) == 0) {
            filters[filterCnt].type = LOW;
            filters[filterCnt].freq = atof(nextArg(&argString, 4));
            filterCnt++;
        } else if (strncmp(argString, "-high", 5) == 0) {
            filters[filterCnt].type = HIGH;
            filters[filterCnt].freq = atof(nextArg(&argString, 5));
            filterCnt++;
        } else if (strncmp(argString, "-peaking", 8) == 0) {
            filters[filterCnt].type = PEAKING;
            filters[filterCnt].freq = atof(nextArg(&argString, 8));
            filters[filterCnt].bw = atof(nextArg(&argString, 0));
            filterCnt++;
        } else if (strncmp(argString, "-fs", 3) == 0) {
            Fs = atof(nextArg(&argString, 3));
        } else if (strncmp(argString, "-bits", 5) == 0) {
            FRACTIONALBITS = atoi(nextArg(&argString, 5));
        } else if (strncmp(argString, "-min", 4) == 0) {
            mindb = atof(nextArg(&argString, 4));
        } else if (strncmp(argString, "-max", 4) == 0) {
            maxdb = atof(nextArg(&argString, 4));
        } else if (strncmp(argString, "-step", 5) == 0) {
            stepdb = atof(nextArg(&argString, 5));
        } else if (strncmp(argString, "-h", 2) == 0) {
            includeFile = nextArg(&argString, 2);
        } else if (strncmp(argString, "-xc", 3) == 0) {
            sourceFile = nextArg(&argString, 3);
        } else if (strncmp(argString, "-csv", 4) == 0) {
            responseCurve = nextArg(&argString, 4);
        } else {
            usage();
        }

    }
    dbcnt = floor((maxdb-mindb+stepdb/4)/stepdb) + 1;
    if (mindb >= maxdb) {
        fprintf(stderr, "Mindb should be less than maxdb\n");
        exit(1);
    }
    if (dbcnt > maxDbs) {
        fprintf(stderr, "Too many steps in db (>= %d), recompile the source\n", maxDbs);
        exit(1);
    }
    fdH = fopen_save(includeFile);
    fdXC = fopen_save(sourceFile);
    fdCSV = fopen_save(responseCurve);

    for(i = 0, f = 10; i < hzCnt; i++, f *= 1.18920711500272106671) {
        freqs[i] = f;
    }

    fprintf(fdH,
            "//Generated code - do not edit.\n\n"
            "#define BANKS %d\n"
            "#define DBS %d\n"
           "#define FRACTIONALBITS %d\n"
            "#ifdef __XC__\n"
            "extern struct coeff {int b0, b1, b2, a1, a2;} biquads[DBS][BANKS];\n\n",
            filterCnt, dbcnt, FRACTIONALBITS );

    fprintf(fdH,
            "typedef struct {\n"
            "    struct {int xn1; int xn2; int db;} b[BANKS+1];\n"
            "    int adjustDelay;\n"
            "    int adjustCounter;\n"
            "    int desiredDb[BANKS];\n"
            "} biquadState;\n\n"
            "extern void initBiquads(biquadState &state, int zeroDb);\n"
            "extern int biquadCascade(biquadState &state, int sample);\n"
            "#endif\n"
        );

    fprintf(fdXC,
            "//Generated code - do not edit.\n\n"
            "// First index is the dbLevel, in steps of %f db, first entry is %f db\n"
            "// Second index is the filter number - this filter has %d banks\n"
            "// Each structure instantiation contains the five coefficients for each biquad:\n"
            "// -a1/a0, -a2/a0, b0/a0, b1/a0, b2/a0; all numbers are stored in 2.30 fixed point\n"
            "#include \"%s\"\n"
            "struct coeff biquads[DBS][BANKS] = {\n", stepdb, mindb, filterCnt, includeFile);
    thedb = 0;
    fprintf(fdCSV, "\"\",\"\",");        
    for(f = mindb; f <= maxdb+stepdb/1000; f+=stepdb) {
        fprintf(fdCSV, "\"%5.2f dB\",", f);        
        fprintf(fdXC, "  { //Db: %f\n", f);
        for(i = 0; i < filterCnt; i++) {
            switch(filters[i].type) {
            case LOW:
                lowShelf(filters[i].freq, f);
                break;
            case HIGH:
                highShelf(filters[i].freq, f);
                break;
            case PEAKING:
                peakingEQ(filters[i].freq, f, filters[i].bw);
                break;
            }
        }
        thedb++;
        fprintf(fdXC, "  },\n");
    }
    fprintf(fdXC, "};\n");
    fprintf(fdCSV, "\n");
    for(i = 0; i < hzCnt; i++) {
        fprintf(fdCSV, "\"%f\",\"Hz\",", freqs[i]);
        for(j = 0; j<dbcnt; j++) {
            fprintf(fdCSV, "\"%f\",", gain[j][i]);
        }
        for(j = 0; j<dbcnt; j++) {
            fprintf(fdCSV, "\"%f\",", gain[j][i] - igain[j][i]);
        }
        fprintf(fdCSV, "\n");
    }
    return errorValue;
}
