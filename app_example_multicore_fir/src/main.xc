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

#define ntaps 3000			   //Number of FIR filter taps

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
		on stdcore[3]:
		{
			int samples;
			int h[ntaps];
			int x[2 * ntaps];
			par{
				fir_MultiCore(c, cdc, ntaps);
				samples=test_performance(c, ntaps);
			}
			calc_CRC(h,x,ntaps,samples);
			while(1); //Temporary protection for incorrect release of resourses
			printstrln("Press stop button to kill process!");
		}
	}
	return 0;
}

