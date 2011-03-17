// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <stdio.h>
#include <xs1.h>
#include "coeffs.h"

void initBiquads(biquadState &state, int zeroDb) {
    for(int i = 0; i <= BANKS; i++) {
        state.xn1[i] = 0;
        state.xn2[i] = 0;
    }
    for(int i = 0; i < BANKS; i++) {
        state.db[i] = zeroDb;
        state.desiredDb[i] = zeroDb;
    }
    state.adjustCounter = BANKS;
    state.adjustDelay = 0;
}

#pragma unsafe arrays
int biquadCascade(biquadState &state, int xn) {
    unsigned int ynl;
    int ynh;

#pragma loop unroll(5)
    for(int j=0; j<BANKS; j++) {
        ynl = (1<<23);        // 0.5, for rounding, could be triangular noise
        ynh = 0;
        {ynh, ynl} = macs( biquads[state.db[j]][j].a1, state.xn1[j+1], ynh, ynl);
        {ynh, ynl} = macs( biquads[state.db[j]][j].a2, state.xn2[j+1], ynh, ynl);
        {ynh, ynl} = macs( biquads[state.db[j]][j].b0, xn, ynh, ynl);
        {ynh, ynl} = macs( biquads[state.db[j]][j].b1, state.xn1[j], ynh, ynl);
        {ynh, ynl} = macs( biquads[state.db[j]][j].b2, state.xn2[j], ynh, ynl);
        if (sext(ynh,24) == ynh) {
            ynh = (ynh << 8) | (((unsigned) ynl) >> 24);
        } else if (ynh < 0) {
            ynh = 0x80000000;
        } else {
            ynh = 0x7fffffff;
        }
        if (j == BANKS-1) {
            state.xn2[j+1] = state.xn1[j+1];
            state.xn1[j+1] = ynh;
        }
        state.xn2[j] = state.xn1[j];
        state.xn1[j] = xn;

        xn = ynh;
    }
    
    if (state.adjustDelay > 0) {
        state.adjustDelay--;
    } else {
        state.adjustCounter--;
        if (state.db[state.adjustCounter] > state.desiredDb[state.adjustCounter]) {
            state.db[state.adjustCounter]--;
        }
        if (state.db[state.adjustCounter] < state.desiredDb[state.adjustCounter]) {
            state.db[state.adjustCounter]++;
        }
        if (state.adjustCounter == 0) {
            state.adjustCounter = BANKS;
        }
        state.adjustDelay = 40;
    }
    return xn;
}

