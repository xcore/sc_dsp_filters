// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
//
#include <xs1.h>
#include "fir.h"
#include <print.h>

#define LDAW(ptrout,ptrin,offset) asm("ldaw %0,%1[%2]": "=r"(ptrout) : "r"(ptrin) ,"r"(offset))

int distribute(streaming chanend c, streaming chanend cd[4], int x[],
		unsigned ntaps) {
	int hi, addhi, state = 0;
	unsigned lo, addlo;
	int samples;
	while (1) {
		if (stestct(c)) {
			sinct(c);
			for (int i = 0; i < THREADS; i++)
				soutct(cd[i], 10);
			c:>samples;
			return samples;
		}
		else {
			c:>x[state];
			x[state+ntaps]=state;
#pragma loop unroll
			for(int i=0;i<THREADS;i++)
			cd[i]<:state;
			state--;
			if(state<0)
			state+=ntaps;
			cd[0]:>lo;
			cd[0]:>hi;
#pragma loop unroll
			for(int i=1;i<THREADS;i++) {
				cd[i]:>addlo;
				{	hi,lo}=mac(1,addlo,hi,lo);
			}
#pragma loop unroll
			for(int i=1;i<THREADS;i++) {
				cd[i]:>addhi;
				hi+=addhi;
			}
			c<: hi<<8 | lo>>24;
		}
	}
	return -1;
}

int fir_Multithreading(streaming chanend c, int h[], int x[], unsigned ntaps) {
	streaming chan cd[THREADS];
	int hPtr[THREADS], xPtr[THREADS]; //Pointers to h,x
	int samples;
	for (int i = 0; i < THREADS; i++) {
LDAW		(hPtr[i],h,i*ntaps/THREADS);
		LDAW(xPtr[i],x,i*ntaps/THREADS);
	}
	par {samples=distribute(c,cd,x,ntaps);
		par(int t=0; t< THREADS;t++) {firASM_DoubleData_multiThread(cd[t],xPtr[t],hPtr[t],ntaps);}
		}
	printstrln("\nFiltering Done"); //test only
	return samples;
}

