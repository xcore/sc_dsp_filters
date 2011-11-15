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

#define ntaps 3000

int main() {
	streaming chan c;
	unsigned samples;
	int h[ntaps];
	int x[2*ntaps];
	par{
		fir_Multithreading4(c, h, x, ntaps);
		samples = test_performance(c, ntaps); //Generates samples to the FIR filter
	}
	calc_CRC(h,x,ntaps,samples);
return 0;
}
