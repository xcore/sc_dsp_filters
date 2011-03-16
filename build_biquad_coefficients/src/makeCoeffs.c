// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define pi 3.1415926536

#define hzCnt 139
#define maxDbs 200

double gain[maxDbs][hzCnt];
double freqs[hzCnt];
int thedb;

FILE *fdH, *fdXC, *fdCSV;

int R(double x) {
    return floor((1<<24) * x + 0.5);
}

double Fs = 48000.0;

double sqr(double x) {
    return x*x;
}

void printout(double a0, double a1, double a2, double b0, double b1, double b2) {
    double f;
    int cnt = 0;

    for(cnt = 0; cnt < hzCnt; cnt++) {
        double w = 2 * pi * freqs[cnt] / Fs;
        double phi = sin(w/2);
        phi = phi * phi;
        gain[thedb][cnt] +=
            10*log10( sqr(b0+b1+b2) - 4*(b0*b1 + 4*b0*b2 + b1*b2)*phi + 16*b0*b2*sqr(phi) )
            -10*log10( sqr(a0+a1+a2) - 4*(a0*a1 + 4*a0*a2 + a1*a2)*phi + 16*a0*a2*sqr(phi) );
    }

    fprintf(fdXC, "    {%10d, %10d, %10d, %10d, %10d},\n", -R(a1/a0), -R(a2/a0), R(b0/a0), R(b1/a0), R(b2/a0));
}

void peakingEQ(double f0, double dbGain, double BW) {
    double A = pow(10.0, dbGain / 40.0);
    double w0 = 2 * pi * f0  /Fs;
    double alpha = sin(w0) * sinh(log(2.0)/2.0 * BW * w0/sin(w0));
    double b0 = 1 + alpha * A;
    double b1 = -2 * cos(w0);
    double b2 = 1 - alpha * A;
    double a0 = 1 + alpha / A;
    double a1 = -2 * cos(w0);
    double a2 = 1 - alpha / A;
    printout( a0, a1, a2, b0, b1, b2);
}

void lowShelf(double fin, double dbGain) {
    double f0 = fin;
    double A = pow(10.0, dbGain / 40.0);
    double w0 = 2 * pi * f0  /Fs;
    double S = 1;
    double alpha = sin(w0)/2*sqrt((A+1/A)*(1/S-1)+2);
    double b0 =   A*((A+1)-(A-1)*cos(w0) + 2*sqrt(A)*alpha);
    double b1 = 2*A*((A-1)-(A+1)*cos(w0)                  );
    double b2 =   A*((A+1)-(A-1)*cos(w0) - 2*sqrt(A)*alpha);
    double a0 =     ((A+1)+(A-1)*cos(w0) + 2*sqrt(A)*alpha);
    double a1 =-2*  ((A-1)+(A+1)*cos(w0)                  );
    double a2 =     ((A+1)+(A-1)*cos(w0) - 2*sqrt(A)*alpha);
    printout( a0, a1, a2, b0, b1, b2);
}

void highShelf(double f0, double dbGain) {
    double A = pow(10.0, dbGain / 40.0);
    double w0 = 2 * pi * f0  /Fs;
    double S = 1;
    double alpha = sin(w0)/2*sqrt((A+1/A)*(1/S-1)+2);
    double b0 =   A*((A+1)+(A-1)*cos(w0) + 2*sqrt(A)*alpha);
    double b1 =-2*A*((A-1)+(A+1)*cos(w0)                  );
    double b2 =   A*((A+1)+(A-1)*cos(w0) - 2*sqrt(A)*alpha);
    double a0 =     ((A+1)-(A-1)*cos(w0) + 2*sqrt(A)*alpha);
    double a1 = 2*  ((A-1)-(A+1)*cos(w0)                  );
    double a2 =     ((A+1)-(A-1)*cos(w0) - 2*sqrt(A)*alpha);
    printout( a0, a1, a2, b0, b1, b2);
}

void usage() {
    fprintf(stderr,
            " -low freq            Low shelf filter, with given corner freq\n"
            " -high freq           High shelf filter, with given corner freq\n"
            " -peaking freq bw     PeakingEQ filter, with given corner freq and bw in octaves\n\n"
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

int main(int argc, char *argv[]) {
    double f;
    int dbcnt;
    int filterCnt;
    double mindb=-20, maxdb=20, stepdb=1;
    int i, j;
    char *includeFile = "coeffs.h";
    char *sourceFile = "coeffs.xc";
    char *responseCurve = "response.csv";

    struct {
        double freq, bw;
        int type;
    } filters[100];

    if (argc < 5) usage();
    for( i = 1; i<argc; i++) {
        if (strcmp(argv[i], "-low") == 0) {
            filters[filterCnt].type = LOW;
            filters[filterCnt].freq = atof(argv[++i]);
            filterCnt++;
        } else if (strcmp(argv[i], "-high") == 0) {
            filters[filterCnt].type = HIGH;
            filters[filterCnt].freq = atof(argv[++i]);
            filterCnt++;
        } else if (strcmp(argv[i], "-peaking") == 0) {
            filters[filterCnt].type = PEAKING;
            filters[filterCnt].freq = atof(argv[++i]);
            filters[filterCnt].bw = atof(argv[++i]);
            filterCnt++;
        } else if (strcmp(argv[i], "-fs") == 0) {
            Fs = atof(argv[++i]);
        } else if (strcmp(argv[i], "-min") == 0) {
            mindb = atof(argv[++i]);
        } else if (strcmp(argv[i], "-max") == 0) {
            maxdb = atof(argv[++i]);
        } else if (strcmp(argv[i], "-step") == 0) {
            stepdb = atof(argv[++i]);
        } else if (strcmp(argv[i], "-h") == 0) {
            includeFile = argv[++i];
        } else if (strcmp(argv[i], "-xc") == 0) {
            sourceFile = argv[++i];
        } else if (strcmp(argv[i], "-csv") == 0) {
            responseCurve = argv[++i];
        } else {
            usage();
        }

    }
    dbcnt = (maxdb-mindb)/stepdb + 1.5;
    if (mindb >= maxdb) {
        fprintf(stderr, "Mindb should be less than maxdb\n");
        exit(1);
    }
    if (dbcnt >= maxDbs) {
        fprintf(stderr, "Too many steps in db (>= %d), recompile the source\n", maxDbs);
        exit(1);
    }
    fdH = fopen_save(includeFile);
    fdXC = fopen_save(sourceFile);
    fdCSV = fopen_save(responseCurve);

    for(i = 0, f = 50; i < hzCnt; i++, f *= 1.0442737824274) {
        freqs[i] = f;
    }

    fprintf(fdH,
            "//Generated code - do not edit.\n\n"
            "#define BANKS %d\n"
            "#define DBS %d\n"
            "extern struct coeff {int a1, a2, b0, b1, b2;} biquads[DBS][BANKS];\n\n",
            filterCnt, dbcnt );

    fprintf(fdH,
            "typedef struct {\n"
            "    int xn1[BANKS+1], xn2[BANKS+1];\n"
            "    int db[BANKS];\n"
            "    int desiredDb[BANKS];\n"
            "    int adjustCounter;\n"
            "    int adjustDelay;\n"
            "} biquadState;\n\n"
            "extern void initBiquads(biquadState &state, int zeroDb);\n"
            "extern int biquadCascade(biquadState &state, int sample);\n"
        );

    fprintf(fdXC,
            "//Generated code - do not edit.\n\n"
            "// First index is the dbLevel, in steps of %f db, first entry is %f db\n"
            "// Second index is the filter number - this filter has %d banks\n"
            "// Each structure instantiation contains the five coefficients for each biquad:\n"
            "// -a1/a0, -a2/a0, b0/a0, b1/a0, b2/a0; all numbers are stored in 8.24 fixed point\n"
            "#include \"%s\"\n"
            "struct coeff biquads[DBS][BANKS] = {\n", stepdb, mindb, filterCnt, includeFile);
    thedb = 0;
    fprintf(fdCSV, "\"\",\"\",", f);        
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
        fprintf(fdXC, "  },\n", f);
    }
    fprintf(fdXC, "};\n");
    fprintf(fdCSV, "\n");
    for(i = 0; i < hzCnt; i++) {
        fprintf(fdCSV, "\"%f\",\"Hz\",", freqs[i]);
        for(j = 0; j<dbcnt; j++) {
            fprintf(fdCSV, "\"%f\",", gain[j][i]);
        }
        fprintf(fdCSV, "\n");
    }
    return 0;
}
