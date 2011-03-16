// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <stdio.h>
#include <xs1.h>

#pragma unsafe arrays
int fir(int xn, int coeffs[], int state[], int ELEMENTS) {
    unsigned int ynl;
    int ynh;

    ynl = (1<<23);        // 0.5, for rounding, could be triangular noise
    ynh = 0;
    state[ELEMENTS-1] = xn;
    for(int j=0; j<ELEMENTS-1; j++) {
        {ynh, ynl} = macs(coeffs[j], state[j], ynh, ynl);
        state[j] = state[j+1];
    }
    {ynh, ynl} = macs(coeffs[ELEMENTS-1], xn, ynh, ynl);
    ynh = (ynh << 8) | (((unsigned) ynl) >> 24);
    return ynh;
}

