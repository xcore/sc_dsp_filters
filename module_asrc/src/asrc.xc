// Copyright (c) 2012, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <xs1.h>
#include <stdio.h>
#include "asrc.h"
#include "coeffs.h"

#define NEITHER   0
#define DELETING  1
#define INSERTING 2

void asrcInit(struct asrcState &state) {
    state.wr = 0;
    for(int i = 0; i < ASRC_ARRAY; i++) {
        state.buffer[i] = 0;
    }
    state.firStart = -1;
    state.state    = NEITHER;
}

#pragma unsafe arrays

int asrcFilter(int sample, int diff, struct asrcState &state) {
    int wr;
    int h = 0;
    unsigned l = 0;
    int rd;
    int firPosition;

    if(diff == 1) {
        state.firStart = 1;
        state.state = INSERTING;

        rd = state.wr - (ASRC_ORDER>>1) - 1;  // Pick one ahead of normal read point
        rd &= (ASRC_ARRAY-1);
        return state.buffer[rd];               // and return value
    }

    wr = state.wr;
    state.buffer[wr] = sample;
    wr++;
    wr &= (ASRC_ARRAY-1);
    state.wr = wr;

    if(diff == -1) {
        state.firStart = ASRC_UPSAMPLING-1;
        state.state = DELETING;
        return 0;
    }

    if(state.state == NEITHER) {            // No FIR running.
        int rd = wr - (ASRC_ORDER>>1) - 2;  // Pick normal read point
        rd &= (ASRC_ARRAY-1);               // Weap read pointer
        return state.buffer[rd];            // and return value
    } else if (state.state == DELETING) {
        rd = state.wr + ASRC_ARRAY - ASRC_ORDER - 2;
        rd &= (ASRC_ARRAY-1);
        firPosition = state.firStart;
        state.firStart--;
        if (state.firStart == 0) {
            state.state = NEITHER;
        }
    } else {                               // INSERTING
        rd = state.wr + ASRC_ARRAY - ASRC_ORDER - 1;
        rd &= (ASRC_ARRAY-1);
        firPosition = state.firStart;
        state.firStart++;
        if (state.firStart == ASRC_UPSAMPLING) {
            state.state = NEITHER;
        }
    }

    // we have a FIR running, execute over all ASRC_ORDER points
#pragma loop unroll
    for(int i = 0; i < ASRC_ORDER; i++) {
        {h,l} = macs(asrcCoeffs[firPosition], state.buffer[rd], h, l);
        firPosition += ASRC_UPSAMPLING;
        rd++;
        rd &= (ASRC_ARRAY-1);
    }
    h = h << 8 | l >> 24;

    return h;
}
