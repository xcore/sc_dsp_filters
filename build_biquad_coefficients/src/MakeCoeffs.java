// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

import java.lang.Math;
import java.io.*;
import java.util.*;

class MakeCoeffs {
    final double pi = Math.PI;
    int FRACTIONALBITS = 24;

    final int hzCnt = 42;
    final int maxDbs = 41;

    double [][]gain = new double[maxDbs][hzCnt];
    double [][]igain = new double[maxDbs][hzCnt];
    double []freqs = new double[hzCnt];
    int thedb;

    PrintStream fdH, fdXC, fdCSV;

    static int errorValue = 0;
    
    int R(double x) {
        if (x >= (1<<(31-FRACTIONALBITS)) ||
            x < -(1<<(31-FRACTIONALBITS))) {
            System.err.print("Overflow: constant " + x + " too large, maximum with " + FRACTIONALBITS + " fractional bits is " + (1<<(31-FRACTIONALBITS)));
            errorValue++;
        }
        return (int) Math.floor((1<<FRACTIONALBITS) * x + 0.5);
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
            double phi = Math.sin(w/2);
            phi = phi * phi;
            igain[thedb][cnt] +=
                10*Math.log10( sqr(b0+b1+b2) - 4*(b0*b1 + 4*b0*b2 + b1*b2)*phi + 16*b0*b2*sqr(phi) )
                -10*Math.log10( sqr(a0+a1+a2) - 4*(a0*a1 + 4*a0*a2 + a1*a2)*phi + 16*a0*a2*sqr(phi) );
            gain[thedb][cnt] +=
                10*Math.log10( sqr(rb0+rb1+rb2) - 4*(rb0*rb1 + 4*rb0*rb2 + rb1*rb2)*phi + 16*rb0*rb2*sqr(phi) )
                -10*Math.log10( sqr(ra0+ra1+ra2) - 4*(ra0*ra1 + 4*ra0*ra2 + ra1*ra2)*phi + 16*ra0*ra2*sqr(phi) );
        }
        
        fdXC.print("    {" + R(b0/a0) + ", " + R(b1/a0) + ", " + R(b2/a0) + ", " +
                           (-R(a1/a0)) + ", " + (-R(a2/a0)) + "},\n");
    }
    
    void peakingEQ(double f0, double dbGain, double BW) {
        double A = Math.pow(10.0, dbGain / 40.0);
        double w0 = 2 * pi * f0  /Fs;
        double cosw0 = Math.cos(w0);
        double sinw0 = Math.sin(w0);
        double alpha = sinw0 * Math.sinh(Math.log(2.0)/2.0 * BW * w0/sinw0);
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
        double A = Math.pow(10.0, dbGain / 40.0);
        double w0 = 2 * pi * f0  /Fs;
        double cosw0 = Math.cos(w0);
        double sqrtA = Math.sqrt(A);
        double S = 1;
        double alpha = Math.sin(w0)/2*Math.sqrt((A+1/A)*(1/S-1)+2);
        double b0 =   A*((A+1)-(A-1)*cosw0 + 2*sqrtA*alpha);
        double b1 = 2*A*((A-1)-(A+1)*cosw0                );
        double b2 =   A*((A+1)-(A-1)*cosw0 - 2*sqrtA*alpha);
        double a0 =     ((A+1)+(A-1)*cosw0 + 2*sqrtA*alpha);
        double a1 =-2*  ((A-1)+(A+1)*cosw0                );
        double a2 =     ((A+1)+(A-1)*cosw0 - 2*sqrtA*alpha);
        printout( a0, a1, a2, b0, b1, b2);
    }
    
    void highShelf(double f0, double dbGain) {
        double A = Math.pow(10.0, dbGain / 40.0);
        double w0 = 2 * pi * f0  /Fs;
        double cosw0 = Math.cos(w0);
        double sqrtA = Math.sqrt(A);
        double S = 1;
        double alpha = Math.sin(w0)/2*Math.sqrt((A+1/A)*(1/S-1)+2);
        double b0 =   A*((A+1)+(A-1)*cosw0 + 2*sqrtA*alpha);
        double b1 =-2*A*((A-1)+(A+1)*cosw0                );
        double b2 =   A*((A+1)+(A-1)*cosw0 - 2*sqrtA*alpha);
        double a0 =     ((A+1)-(A-1)*cosw0 + 2*sqrtA*alpha);
        double a1 = 2*  ((A-1)-(A+1)*cosw0                );
        double a2 =     ((A+1)-(A-1)*cosw0 - 2*sqrtA*alpha);
        printout( a0, a1, a2, b0, b1, b2);
    }
    
    void usage() {
        System.err.print(
                " -low freq            Low shelf filter, with given corner freq\n" + 
                " -high freq           High shelf filter, with given corner freq\n" + 
                " -peaking freq bw     PeakingEQ filter, with given corner freq and bw in octaves\n\n" + 
                " -bits fractionalBits number of fractional bits, default 24\n" + 
                " -min minDb           minimal dB value, default -20\n" + 
                " -max maxDb           maximal dB value, default +20\n" + 
                " -step dbStep         Dbs between each step, default 1\n" + 
                " -fs freq             Sample frequency, default 48000\n\n" + 
                " -h includeFileName   name of include file, default coeffs.h\n" + 
                " -xc sourceFileName   name of source file, default coeffs.xc\n" + 
                " -csv csvFileName     name of csv file, default response.csv\n\n" + 
                "eg:  -min -20 -max 20 -step 4 -low 250 -high 4000\n" + 
                "or   -min -20 -max 20 -low 400 -peaking 800 1 -peaking 1600 1 -high 3200\n" + 
                "Outputs are\n" + 
                " an include file for specific filter banks\n" + 
                " a source code file that initialises the coefficients table\n" + 
                " a CSV file that contains the response curves\n" 
            );
        System.exit(0);
    }

    PrintStream fopen_save(String x) {
        try {
            return new PrintStream(x);
        } catch(Exception e) {
            System.err.println("Cannot open " + x);
            usage();
        }
        return null;
    }
    
    final int LOW = 0;
    final int HIGH = 1;
    final int PEAKING = 2;
    
    static class F {
        double freq, bw;
        int type;
        F(int t, double x, double y) {
            type = t; freq = x; bw = y;
        }
    };
    public static void main(String[] args) {
        new MakeCoeffs(args);
        // return errorValue;
    }

    MakeCoeffs(String[] args){
        double f;
        int dbcnt;
        int filterCnt = 0;
        double mindb=-20, maxdb=20, stepdb=1;
        int j;
        String includeFile = "coeffs.h";
        String sourceFile = "coeffs.xc";
        String responseCurve = "response.csv";
            
        Vector<F> filters = new Vector<F>();
        
        for(int i = 0; i < args.length; i++) {
            if (args[i].equals( "-low") ) {
                filters.add(new F(LOW, Double.parseDouble(args[++i]), 0));
                filterCnt++;
            } else if (args[i].equals( "-high") ) {
                filters.add(new F(HIGH, Double.parseDouble(args[++i]) , 0));
                filterCnt++;
            } else if (args[i].equals( "-peaking") ) {
                filters.add(new F(PEAKING, Double.parseDouble(args[i+1]), Double.parseDouble(args[i+2])));
                i += 2;
                filterCnt++;
            } else if (args[i].equals( "-fs") ) {
                Fs = Double.parseDouble(args[++i]);
            } else if (args[i].equals( "-bits") ) {
                FRACTIONALBITS = Integer.parseInt(args[++i]);
            } else if (args[i].equals( "-min") ) {
                mindb = Double.parseDouble(args[++i]);
            } else if (args[i].equals( "-max") ) {
                maxdb = Double.parseDouble(args[++i]);
            } else if (args[i].equals( "-step") ) {
                stepdb = Double.parseDouble(args[++i]);
            } else if (args[i].equals( "-h") ) {
                includeFile = args[++i] ;
            } else if (args[i].equals( "-xc") ) {
                sourceFile = args[++i] ;
            } else if (args[i].equals( "-csv") ) {
                responseCurve = args[++i];
            } else {
                usage();
            }
            
        }
        dbcnt = (int) Math.floor((maxdb-mindb+stepdb/4)/stepdb) + 1;
        if (mindb > maxdb) {
            System.err.print("Mindb should be less than or equal to maxdb\n");
            System.exit(1);
        }
        if (dbcnt > maxDbs) {
            System.err.println("Too many steps in db (>= " + maxDbs + "), recompile the source\n");
            System.exit(1);
        }
        fdH = fopen_save(includeFile);
        fdXC = fopen_save(sourceFile);
        fdCSV = fopen_save(responseCurve);
        f = 10;
        for(int i = 0; i < hzCnt; i++, f *= 1.18920711500272106671) {
            freqs[i] = f;
        }
        
        fdH.print(
                "//Generated code - do not edit.\n\n" + 
                "#define BANKS " + filterCnt + "\n" + 
                "#define DBS "+ dbcnt +  " \n" + 
                "#define FRACTIONALBITS " + FRACTIONALBITS + "\n"
            );
        
        fdXC.print(
                "//Generated code - do not edit.\n\n" + 
                "// First index is the dbLevel, in steps of " + stepdb + " db, first entry is " + mindb + " db\n" + 
                "// Second index is the filter number - this filter has " + filterCnt + " banks\n" + 
                "// Each structure instantiation contains the five coefficients for each biquad:\n" + 
                "// b0/a0, b1/a0, b2/a0, -a1/a0, -a2/a0; all numbers are stored in 2.30 fixed point\n" + 
                "#include \"" + includeFile + "\"\n" + 
                "#include \"biquadCascade.h\"\n" + 
                "struct coeff biquads[DBS][BANKS] = {\n");
        thedb = 0;
        fdCSV.print("\"\",\"\",");        
        for(f = mindb; f <= maxdb+stepdb/1000; f+=stepdb) {
            fdCSV.print("\"" + f + " dB\",");        
            fdXC.print("  { //Db: " + f + "\n");
            for(F ff: filters) {
                switch(ff.type) {
                case LOW:
                    lowShelf(ff.freq, f);
                    break;
                case HIGH:
                    highShelf(ff.freq, f);
                    break;
                case PEAKING:
                    peakingEQ(ff.freq, f, ff.bw);
                    break;
                }
            }
            thedb++;
            fdXC.print("  },\n");
        }
        fdXC.print("};\n");
        fdCSV.print("\n");
        for(int i = 0; i < hzCnt; i++) {
            fdCSV.print( "\""+freqs[i]+"\",\"Hz\",");
            for(j = 0; j<dbcnt; j++) {
                fdCSV.print( "\""+gain[j][i]+"\",");
            }
            for(j = 0; j<dbcnt; j++) {
                fdCSV.print( "\""+(gain[j][i] - igain[j][i])+"\",");
            }
            fdCSV.print( "\n");
        }
    }
}