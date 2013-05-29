// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
//
#include <xs1.h>
#include "fir.h"


void distribute(streaming chanend c, streaming chanend cd[],int h[],int x[], unsigned ntaps,const unsigned threads) {
    int hi, addhi;
    unsigned lo, addlo;
    int state = ntaps-1;
    int tmp;
    int done=0;

    if(stestct(c)){
    	/* update the filter coef*/
      for(int i=0;i<ntaps;i++){
    	  c:>tmp;
    	  h[i]=tmp;
    }
    soutct(c,9);
    }
    c:>x[0];
    x[ntaps]=x[0];
#pragma loop unroll
    for(int i=0;i<threads;i++)
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
            for(int i=0;i<threads;i++)
                cd[i]<:state;
        }
        cd[0]:>lo;
        cd[0]:>hi;
        
#pragma loop unroll
        for(int i=1;i<threads;i++) {
            cd[i]:>addlo;
            {hi,lo}=mac(1,addlo,hi,lo);
        }
        
#pragma loop unroll
        for(int i=1;i<threads;i++) {
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
    for(int i=0;i<threads;i++)
        soutct(cd[i], 10); //Kill all dist. threads
}


int fir_Multithreading4(streaming chanend c, int h[], int x[], unsigned ntaps){
	streaming chan cd[4];
	int hPtr[4], xPtr[4]; //Pointers to h,x
    if(ntaps%4!=0){
        return -1;
    }
	for(int i=0;i<ntaps;i++){
		c:>h[i];
		x[i]=0;
		x[i+ntaps]=0;
	}
	schkct(c,9); // Check that all filter taps was sent
    for (int i = 0; i < 4; i++) {
        LDAW(hPtr[i],h,i*ntaps/4);
        LDAW(xPtr[i],x,i*ntaps/4);
    }
    par {
        distribute(c,cd,h,x,ntaps,4);
        par(int i=0;i<4;i++){firASM_DoubleData_multiThread(cd[i],hPtr[i],xPtr[i],ntaps/4);}
    }

#if 0
    par {// Compiler workaround for XDE 11.2
       asm("" : : "r"(cd));
       asm("" : : "r"(cd));
     }
    par{  // Compiler workaround for XDE 11.2
        disconnect(cd, 4);
        disconnect(cd, 4);
    }
#endif
return 0;
}

int fir_Multithreading3(streaming chanend c, int h[], int x[], unsigned ntaps){
	streaming chan cd[3];
	int hPtr[3], xPtr[3]; //Pointers to h,x
    if(ntaps%3!=0){
        return -1;
    }
	for(int i=0;i<ntaps;i++){
		c:>h[i];
		x[i]=0;
		x[i+ntaps]=0;
	}
	schkct(c,9); // Check that all filter taps was sent
    for (int i = 0; i < 3; i++) {
        LDAW(hPtr[i],h,i*ntaps/3);
        LDAW(xPtr[i],x,i*ntaps/3);
    }
    par {
        distribute(c,cd,h,x,ntaps,3);
        par(int i=0;i<3;i++){firASM_DoubleData_multiThread(cd[i],hPtr[i],xPtr[i],ntaps/3);}
    }

#if 0
    par {// Compiler workaround for XDE 11.2
       asm("" : : "r"(cd));
       asm("" : : "r"(cd));
     }
    par{  // Compiler workaround for XDE 11.2
        disconnect(cd, 3);
        disconnect(cd, 3);
    }
#endif
return 0;
}

int fir_Multithreading2(streaming chanend c, int h[], int x[], unsigned ntaps){
	streaming chan cd[2];
	int hPtr[2], xPtr[2]; //Pointers to h,x
    if(ntaps%2!=0){
        return -1;
    }
	for(int i=0;i<ntaps;i++){
		c:>h[i];
		x[i]=0;
		x[i+ntaps]=0;
	}
	schkct(c,9); // Check that all filter taps was sent
    for (int i = 0; i < 2; i++) {
        LDAW(hPtr[i],h,i*ntaps/2);
        LDAW(xPtr[i],x,i*ntaps/2);
    }
    par {
        distribute(c,cd,h,x,ntaps,2);
        par(int i=0;i<2;i++){firASM_DoubleData_multiThread(cd[i],hPtr[i],xPtr[i],ntaps/2);}
    }

#if 0
    par {// Compiler workaround for XDE 11.2
       asm("" : : "r"(cd));
       asm("" : : "r"(cd));
     }
    par{  // Compiler workaround for XDE 11.2
        disconnect(cd, 2);
        disconnect(cd, 2);
    }
#endif
return 0;
}

int fir_SingleThread(streaming chanend c,int h[],int x[], unsigned ntaps){
	for(int i=0;i<ntaps;i++){
		c:>h[i];
		x[i]=0;
		x[i+ntaps]=0;
	}
	schkct(c,9); // Check that all filter taps was sent
    firASM_DoubleData_singleThread(c, h, x, ntaps);
return 0;
}


