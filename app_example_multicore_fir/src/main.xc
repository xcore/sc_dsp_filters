// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
/*
 *FIR filtering using a channel as Input and Output for data, running on several distributed threads and on several cores.
 *Uses the double data method and Q8.24
 */

#include <platform.h>
#include <print.h>
#include <xs1.h>
#include <fir.h>

#define sec XS1_TIMER_HZ
#define ntaps 3000			   //Number of FIR filter taps
#define POLYNOMIAL 0xEDB88320  //Used for crc32 checksum
#define MASTERCORE 3


int test_performance(streaming chanend c) {
	timer t;
	int time,samples;
	int done=0;
	unsigned crc = 0;
	int ans = 0, i = 1;

    printstrln("!WARNING! - THIS CODE IS NOT READY FOR RELEASE REGARDING THE CORRECT FILTER OUTPUT");
	printstr("Testing performance, Running FIR-filter for 1 sec on 3 cores with 4 threads/core with ");
	printint(ntaps);
	printstrln(" filter taps");
	t:> time;
	c<:i; //Send first sample directly after the timing started
	i++;
	c<:i;
	time+=sec;
		while(!done) {
			select {
		        case c:>ans:
				crc32(crc, ans, POLYNOMIAL);
				i++;
				c<:i;
				break;
			    case t when timerafter (time) :> void:
				soutct(c,10); //end FIR filter
				c:>ans; //fetch last filtered number in channel buffer.
				crc32(crc, ans, POLYNOMIAL);
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

	return 1;
}

int main() {
	streaming chan c, cdc[CORES];
	par {
		par(int c=0;c<CORES;c++) {on stdcore[c]:
			{
				int h[ntaps/CORES];
				int x[2 * ntaps];
				for (int i = 0; i < 2 * ntaps; i++)
					x[i] = 0; //reset the filter state
				fir_Multithreading4(cdc[c], h, x, ntaps/CORES);
			} }
		on stdcore[MASTERCORE]:
		{
			int h[ntaps];
			int x[2 * ntaps];
			for (int i = 0; i < ntaps; i++)
				h[i] = (i + 1) << 24; //h holds the filter taps
			par{
			fir_MultiCore(c, cdc ,h);
			test_performance(c);
			}
			calc_CRC(h,x);
		}
	return 0;
}

