// Copyright (c) 2012, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "xs1.h"
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
        if (rd < 0) {
            rd += ASRC_ARRAY;
        }
        return state.buffer[rd];               // and return value
    }

    wr = state.wr;
    state.buffer[wr] = sample;
    wr++;
    if (wr >= ASRC_ARRAY) {
        wr = 0;
    }
    state.wr = wr;

    if(diff == -1) {
        state.firStart = ASRC_ORDER-1;
        state.state = DELETING;
        return 0;
    }

    if(state.state == NEITHER) {                   // Negative firStart: no FIR running.
        int rd = wr - (ASRC_ORDER>>1) - 2;  // Pick normal read point
        if (rd < 0) {
            rd += ASRC_ARRAY;
        }
        return state.buffer[rd];               // and return value
    } else if (state.state == DELETING) {
        rd = state.wr;
        firPosition = state.firStart;
        state.firStart--;
        if (state.firStart == 0) {
            state.state = NEITHER;
        }
    } else {                               // INSERTING
        rd = state.wr+1;
        if (rd >= ASRC_ARRAY) {
            rd -= ASRC_ARRAY;
        }
        firPosition = state.firStart;
        state.firStart++;
        if (state.firStart == 8) {
            state.state = NEITHER;
        }
    }

    // non negative firStart - we have a FIR running, execute over all 8 points:

    for(int i = 0; i < ASRC_ORDER; i++) {
        {h,l} = macs(asrcCoeffs[firPosition], state.buffer[rd], h, l);
        firPosition += ASRC_ORDER;
        rd++;
        if (rd >= ASRC_ARRAY) {
            rd -= ASRC_ARRAY;
        }
    }
    h = h << 11 | l >> 21;
    return h;
}
