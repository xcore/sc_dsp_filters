// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*
 * main.xc
 *
 *  Created on: 14 okt 2011
 *      Author: Mikael Bohman
 *
 *
 *FIR filtering using a channel as Input and Output running on one thread.
 *Uses the double data method and Q8.24
*/
#include <platform.h>
#include <print.h>
#include <xs1.h>
#include <fir.h>

#define sec XS1_TIMER_HZ
#define ntaps 3000			   //Number of FIR filter taps
#define POLYNOMIAL 0xEDB88320  //Used for crc32 checksum



int test_performance(streaming chanend c) {
	timer t;
	int time;
	unsigned crc = 0;
	int ans = 0, i = 1;
	printstrln("Testing performance, Running FIR-filter for 1 sec on a single thread with");
	printint(ntaps);
	printstrln(" filter taps");
	t:> time;
	c<:i; //Send first sample directly after the timing started
	time+=sec;
	while(1) {
		select {
			default:
			i++;
			c<:i;
			c:>ans;
			crc32(crc, ans, POLYNOMIAL);
			break;
			case t when timerafter (time) :> void:
			c:>ans;
			crc32(crc, ans, POLYNOMIAL);
			soutct(c,10); //end FIR thread
			printstr("Filtered ");
			printint(i);
			printstrln(" samples during 1 second");
			printint(i*3);
			printstrln(" kTaps per sec.");
			printstr("CRC32 checksum for all filtered samples was: 0x");
			printhex(crc);
			return i;
		}
	}
	return -1;
}

int main() {
	streaming chan c;

	//Init the arrays
	int ans;

	unsigned crc = 0;
	unsigned samples;
	int x[2 * ntaps];
	int h[ntaps];
	for (int i = 0; i < ntaps; i++) {
		h[i] = (i + 1)<<24;
		x[i] = 0;
		x[i + ntaps] = 0;
	}par {
		firASM_DoubleData_singleThread(c, h, x, ntaps);
		samples = test_performance(c);
	}
	for (int i = 0; i < ntaps; i++) {
		x[i] = 0;
	}
	printstrln(
			"\nCalculating the CRC32 checksum from the XC implementation, this might take some time");
	for (int i = 1; i <= samples; i++) {
		ans = fir(i, h, x, ntaps);
		crc32(crc, ans, POLYNOMIAL);
	}
	printstr("Correct Checksum for filtered datasequence is: 0x");
	printhex(crc);
	while (1); // Program doesn't halt correctly ??

return 0;
}
