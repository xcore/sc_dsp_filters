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
 *FIR filtering using a channel as Input and Output for data, running on several distributed threads on several cores.
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
	int time,samples;
	int done=0;
	unsigned crc = 0;
	int ans = 0, i = 1;
	int h[ntaps];		/**** TESTING PURPOSE ONLY ****/
	int x[2 * ntaps];	/**** TESTING PURPOSE ONLY ****/

    printstrln("!WARNING! - THIS CODE IS NOT READY FOR RELEASE REGARDING THE CORRECT FILTER OUTPUT");
	printstr("Testing performance, Running FIR-filter for 1 sec on 3 cores with 4 threads/core with ");
	printint(ntaps);
	printstrln(" filter taps");
	t:> time;
	c<:i; //Send first sample directly after the timing started
	time+=sec;
	while(!done) {
		select {
			default:
			i++;
			c<:i;
			c:>ans;
			crc32(crc, ans, POLYNOMIAL);
			//printint(ans);
			//printstr(", ");
			break;
			case t when timerafter (time) :> void:
			//printstr("\n ending ");
			soutct(c,10); //end FIR filter
			//printstr("\n Sending kill ");
			c:>ans; //fetch last filtered number in channel buffer.
			//printstr("\n Collect last ");
			crc32(crc, ans, POLYNOMIAL);
			//printstr("\nFiltered ");
			printint(i);
			printstrln(" samples during 1 second");
			printint(i*ntaps/1000);
			printstrln(" kTaps per sec.");
			printstr("CRC32 checksum for all filtered samples was: 0x");
			printhexln(crc);
			done=1;
			break;
		}
	}
	/**** TESTING PURPOSE ONLY ****/
	samples=i;
	crc=0;
	for (int i = 0; i < 2*ntaps; i++)
		x[i] = 0; //reset the filter state
	for (int i = 0; i < ntaps; i++)
		h[i] = (i + 1) << 24; //h holds the filter taps
	printstrln("Calculating the CRC32 checksum from the XC implementation, this might take some time");
	for (int i = 1; i <= samples; i++) {
		ans = fir(i, h, x, ntaps);
		crc32(crc, ans, POLYNOMIAL);
	}
	printstr("Correct Checksum for filtered datasequence is: 0x");
	printhexln(crc);

	return 1;
}

int main() {
	streaming chan c, cdc[CORES];
	par {
		par(int c=0;c<CORES;c++) {on stdcore[c]:
			{
				int h[ntaps/CORES];
				int x[2 * ntaps];
				for (int i = 0; i < ntaps/CORES; i++)
					h[i] = (c * ntaps / CORES + (i + 1)) << 24; //h holds the filter taps
				for (int i = 0; i < 2 * ntaps; i++)
					x[i] = 0; //reset the filter state
				fir_Multithreading4(cdc[c], h, x, ntaps/CORES);
			} }
		on stdcore[3]:fir_MultiCore(c, cdc);
		on stdcore[3]:test_performance(c);
	}
	return 0;
}

