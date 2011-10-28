// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
//
#include <xs1.h>
#include "fir.h"

#define LDAW(ptrout,ptrin,offset) asm("ldaw %0,%1[%2]": "=r"(ptrout) : "r"(ptrin) ,"r"(offset))
#define CAST(ptrout,ptrin) asm("add %0,%1,0": "=r"(ptrout):"r"(ptrin))

void disconnect(streaming chanend c[THREADS], unsigned size) {
    for (unsigned i = 0; i < size; i++) {
    //printf("\nKilling channel cd %d",i);
        soutct(c[i], XS1_CT_END);
        schkct(c[i], XS1_CT_END);
    }
}

void distribute(streaming chanend c, streaming chanend cd[THREADS],int x[], unsigned ntaps) {
    int hi, addhi;
    unsigned lo, addlo;
    int state = ntaps-1;
    int done = 0;
    
    c:>x[0];
    x[ntaps]=x[0];
#pragma loop unroll
    for(int i=0;i<THREADS;i++)
        cd[i]<:state;
    
    while (!done) {
        done = stestct(c);
        if (!done) {
            c:>x[state];
            x[state+ntaps]=x[state];
            if(state!=0)
                state--;
            else
                state+=ntaps-1;
#pragma loop unroll
            for(int i=0;i<THREADS;i++)
                cd[i]<:state;
        }
        cd[0]:>lo;
        cd[0]:>hi;
        
#pragma loop unroll
        for(int i=1;i<THREADS;i++) {
            cd[i]:>addlo;
            {hi,lo}=mac(1,addlo,hi,lo);
        }
        
#pragma loop unroll
        for(int i=1;i<THREADS;i++) {
            cd[i]:>addhi;
            hi+=addhi;
        }
        if (sext(hi,24) == hi)
            c <: hi << 8 | lo >> 24;
        else if (hi < 0)
            c <: 0x80000000;
        else
            c <: 0x7fffffff;
    }
    sinct(c);
    for(int i=0;i<THREADS;i++)
        soutct(cd[i], 10); //Kill all dist. threads
}

int fir_Multithreading(streaming chanend c, int h[], int x[], unsigned ntaps) {
    streaming chan cd[THREADS];
    int hPtr[THREADS], xPtr[THREADS]; //Pointers to h,x
    if(ntaps%THREADS!=0){
        return -1;
    }
    for (int i = 0; i < THREADS; i++) {
        LDAW(hPtr[i],h,i*ntaps/THREADS);
        LDAW(xPtr[i],x,i*ntaps/THREADS);
    }
    par {
        distribute(c,cd,x,ntaps);
        par(int i=0;i<THREADS;i++){firASM_DoubleData_multiThread(cd[i],hPtr[i],xPtr[i],ntaps/THREADS);}
    }
    par {// Compiler workaround for XDE 11.2
       asm("" : : "r"(cd));
       asm("" : : "r"(cd));
     }
    par{  // Compiler workaround for XDE 11.2
        disconnect(cd, THREADS);
        disconnect(cd, THREADS);
    }
    return 0;
}

