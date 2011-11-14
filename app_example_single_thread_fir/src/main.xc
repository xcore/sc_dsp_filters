// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

//FIR filtering using a channel as Input and Output running on one thread.
//Uses the double data method and Q8.24

#include <platform.h>
#include <print.h>
#include <xs1.h>
#include <fir.h>

#define ntaps 3000 //Number of FIR filter taps

int main() {
	streaming chan c;
	unsigned samples;
	int x[2 * ntaps];
	int h[ntaps];
	for (int i = 0; i < ntaps; i++) {
		h[i] = (i + 1)<<24;
		x[i] = 0;
		x[i + ntaps] = 0;
	}
	par
	{
		firASM_DoubleData_singleThread(c, h, x, ntaps);
		samples = test_performance(c,ntaps); //Generates samples to the FIR filter
	}
	calc_CRC(h,x,ntaps,samples);

return 0;
}
