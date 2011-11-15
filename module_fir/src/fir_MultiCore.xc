// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "fir.h"
#include <xs1.h>
//#include "print.h"

int fir_MultiCore(streaming chanend c, streaming chanend cdc[], unsigned ntaps) {
	int done = 0;
	int data, temp;
	for(int i=0;i<ntaps;i++){
			c:>temp;
			cdc[CORES*i/ntaps]<:temp; // distribute h to several cores
		}
		schkct(c,9); // Check that all filter taps was sent
		for(int i=0;i<CORES;i++)
		soutct(cdc[i],9);
	c:>data;
#pragma loop unroll
	for(int i=0;i<CORES;i++)
	cdc[i]<:data;

	while (!done) {
		done = stestct(c);
		if(!done) {
			c:>data;
#pragma loop unroll
			for(int i=0;i<CORES;i++)
			cdc[i]<:data;
			cdc[0]:>data;
#pragma loop unroll
			for(int i=1;i<CORES;i++) {
				cdc[i]:>temp;
				data+=temp;
			}
			c<:data;
		}}
	for(int i=0;i<CORES;i++)
	soutct(cdc[i], 10); //Kill all calculations on distributed cores;
	for(int i=1;i<CORES;i++) {
		cdc[i]:>temp;
		data+=temp;
	}
	c<:data;

	return 0;
}
