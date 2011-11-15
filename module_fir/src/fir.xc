// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <print.h>
#include <xs1.h>
#include "fir.h"

#pragma unsafe arrays
int fir(int xn, int coeffs[], int state[], int ELEMENTS) {
    unsigned int ynl;
    int ynh;

    ynl = (1<<23);        // 0.5, for rounding, could be triangular noise
    ynh = 0;
    for(int j=ELEMENTS-1; j!=0; j--) {
        state[j] = state[j-1];
        {ynh, ynl} = macs(coeffs[j], state[j], ynh, ynl);
    }
    state[0] = xn;
    {ynh, ynl} = macs(coeffs[0], xn, ynh, ynl);

    if (sext(ynh,24) == ynh) {
        ynh = (ynh << 8) | (((unsigned) ynl) >> 24);
    } else if (ynh < 0) {
        ynh = 0x80000000;
    } else {
        ynh = 0x7fffffff;
    }

    return ynh;
}

void disconnect(streaming chanend c[], unsigned size) {
    for (unsigned i = 0; i < size; i++) {
    //printf("\nKilling channel cd %d",i);
        soutct(c[i], XS1_CT_END);
        schkct(c[i], XS1_CT_END);
    }
}


void calc_CRC(int h[],int x[],int ELEMENTS,unsigned samples){
		unsigned crc=0;
		int ans;
		for (int i = 0; i < 2*ELEMENTS; i++)
			x[i] = 0; //reset the filter state
		printstrln("Calculating the CRC32 checksum from the XC implementation, this might take some time");
		for (int i = 1; i <= samples; i++) {
			ans = fir(i, h, x, ELEMENTS);
			crc32(crc, ans, POLY);
		}
		printstr("Correct Checksum for filtered datasequence is: 0x");
		printhexln(crc);
}

int test_performance(streaming chanend c,int ELEMENTS){
	timer t;
	int ans,time;
	int i = 1;
	unsigned crc=0;
	for(int i=0;i<ELEMENTS;i++)
		c<: (i + 1) << 24; // sends the filtertaps to the fir filter
    soutct(c,9);
    printstrln("Testing performance, Running FIR-filter for 1 sec");
	printint(ELEMENTS);
	printstrln(" filter taps");
	t:> time;
	c<:i; //Send first sample directly after the timing started
	i++;
	c<:i; //Send second sample directly to fill channel buffers
	time+=XS1_TIMER_HZ;
	while(1) {
		select {
			case c:>ans:
			crc32(crc, ans, POLY);
			i++;
			c<:i;
			break;
			case t when timerafter (time) :> void:
			soutct(c,10); //end FIR thread
			c:>ans; // Fetch second last sample in channel buffer
			crc32(crc, ans, POLY);
			c:>ans; // Fetch last sample in channel buffer
			crc32(crc, ans, POLY);
			printstr("Filtered ");
			printint(i);
			printstrln(" samples during 1 second");
			printint(i*3);
			printstrln(" kTaps per sec.");
			printstr("CRC32 checksum for all filtered samples was: 0x");
			printhexln(crc);
			return i;
			break;
		}
	}
	return -1;
}


