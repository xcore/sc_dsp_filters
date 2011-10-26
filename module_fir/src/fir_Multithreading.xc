// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
//
#include <xs1.h>
#include "fir.h"
#include <print.h>

#define LDAW(ptrout,ptrin,offset) asm("ldaw %0,%1[%2]": "=r"(ptrout) : "r"(ptrin) ,"r"(offset))
#define CAST(ptrout,ptrin) asm("add %0,%1,0": "=r"(ptrout):"r"(ptrin))
void distribute(streaming chanend c, streaming chanend c0,
		streaming chanend c1, streaming chanend c2, streaming chanend c3,
		int x[], unsigned ntaps) {
	int hi, addhi, state = 0;
	unsigned lo, addlo;
	while (1) {
		if (stestct(c)) {
			sinct(c);
			soutct(c0, 10); //Kill all dist. threads
			soutct(c1, 10); //Kill all dist. threads
			soutct(c2, 10); //Kill all dist. threads
			soutct(c3, 10); //Kill all dist. threads
			break;
		} else {
			c:>x[state];
			x[state+ntaps]=state;
			/*#pragma loop unroll
			 for(int i=0;i<THREADS;i++)
			 cd[i]<:state;*/
			state--;
			if(state<0)
				state+=ntaps;

			c0<:state+ntaps;
			c1<:state+ntaps;
			c2<:state+ntaps;
			c3<:state+ntaps; /* TEMP. solution */




			c0:>lo;
			c0:>hi;
			/*#pragma loop unroll
			 for(int i=1;i<THREADS;i++) {
			 cd[i]:>addlo;
			 {	hi,lo}=mac(1,addlo,hi,lo);
			 }*/
			/* TEMP. solution */
			c1:>addlo; {hi,lo}=mac(1,addlo,hi,lo);
			c2:>addlo; {hi,lo}=mac(1,addlo,hi,lo);
			c3:>addlo; {hi,lo}=mac(1,addlo,hi,lo);

			/*#pragma loop unroll
			 for(int i=1;i<THREADS;i++) {
			 cd[i]:>addhi;
			 hi+=addhi;
			 }*/
			/* TEMP. solution */
			c1:>addhi;hi+=addhi;
			c2:>addhi;hi+=addhi;
			c3:>addhi;hi+=addhi;

			c<: hi<<8 | lo>>24;
		}
	}
}

void fir_Multithreading(streaming chanend c, int h[], int x[], unsigned ntaps) {
	streaming chan c0, c1, c2, c3; // Temp solution - awating compiler update to handle arrays of chan outside main()
	int hPtr[THREADS], xPtr[THREADS]; //Pointers to h,x
	for (int i = 0; i < THREADS; i++) {
		LDAW(hPtr[i],h,i*ntaps/THREADS);
		LDAW(xPtr[i],x,i*ntaps/THREADS);
	}
	par {distribute(c,c0,c1,c2,c3,x,ntaps);
		firASM_DoubleData_multiThread(c0,xPtr[0],hPtr[0],ntaps/THREADS);
		firASM_DoubleData_multiThread(c1,xPtr[1],hPtr[1],ntaps/THREADS);
		firASM_DoubleData_multiThread(c2,xPtr[2],hPtr[2],ntaps/THREADS);
		firASM_DoubleData_multiThread(c3,xPtr[3],hPtr[3],ntaps/THREADS);
	}
}

