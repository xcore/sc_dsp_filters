// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>
/*FIR filtering using a channel as Input and Output for data, running on several distributed threads.
 *Uses the double data method and Q8.24
 */
#include <platform.h>
#include <print.h>
#include <xs1.h>
#include <fir.h>

#define NTAPS 3000			   //Number of FIR filter taps
int main() {
	streaming chan c;

	par {
		on stdcore[0]:{
			int h[NTAPS];
			int x[2 * NTAPS];
			int error;
			for (int i = 0; i < NTAPS; i++) {
				h[i] = (i + 1) << 24; //h holds the filter taps
				x[i] = 0; //reset the filter state
				x[i + NTAPS] = 0; //reset the filter state
			}
			error=fir_Multithreading4(c, h, x, NTAPS);
			if(error==-1)
			printstr("\t\t\t!ERROR!\nThe length of the filter must be a multiple of 'THREADS'\n"
					"********************************************************\n");
		}on stdcore[1]:{
			int samples;
			int h[NTAPS];
			int x[2 * NTAPS];
			for (int i = 0; i < NTAPS; i++)
				h[i] = (i + 1) << 24; //h holds the filter taps
				samples = test_performance(c, NTAPS); //Generates samples to the FIR filter
				calc_CRC(h, x, NTAPS, samples);
			}
		}
		return 0;
	}
