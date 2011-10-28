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
 *FIR filtering using a channel as Input and Output for data, running on several distributed threads.
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
	printstr("Testing performance, Running FIR-filter for 1 sec on multithreaded solution with ");
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
			//printint(ans);
			//printstr(", ");
			break;
			case t when timerafter (time) :> void:
			soutct(c,10); //end FIR filter
			c:>ans; //fetch last filtered number in channel buffer.
			crc32(crc, ans, POLYNOMIAL);
			printstr("\nFiltered ");
			printint(i);
			printstrln(" samples during 1 second");
			printint(i*ntaps/1000);
			printstrln(" kTaps per sec.");
			printstr("CRC32 checksum for all filtered samples was: 0x");
			printhexln(crc);
			c<:i;
			return 1;
		}
	}
	return -1;
}

int main() {
	streaming chan c;

	par {
		on stdcore[0]:
		{
			int h[ntaps];
			int x[2 * ntaps];
			int samples,ans;
			unsigned crc=0;
			int error;
			for (int i = 0; i < ntaps; i++) {
				h[i] = (i + 1) << 24; //h holds the filter taps
				x[i] = 0; //reset the filter state
				x[i + ntaps] = 0; //reset the filter state
			}
			error=fir_Multithreading(c, h, x, ntaps);
			if(error==-1)
				printstr("\t\t\t!ERROR!\nThe length of the filter must be a multiple of 'THREADS'\n"
						"********************************************************\n");
			else{
			c:>samples;

			/**** TESTING PURPOSE ONLY ****/
			for (int i = 0; i < 2*ntaps; i++)
				x[i] = 0; //reset the filter state
			printstrln("Calculating the CRC32 checksum from the XC implementation, this might take some time");
			for (int i = 1; i <= samples; i++) {
				ans = fir(i, h, x, ntaps);
				crc32(crc, ans, POLYNOMIAL);
			}
			printstr("Correct Checksum for filtered datasequence is: 0x");
			printhex(crc);
			}

		}on stdcore[1]:
		test_performance(c);
	}

	return 0;
}
