// Copyright (c) 2012, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include "asr.h"
#include "xs1.h"


void asrInit(struct asrState &state) {
    state.wr = 0;
    for(int i = 0; i < ASR_ARRAY; i++) {
        state.buffer[i] = 0;
    }
    state.insertIndex = -1;
}

int asrDelete(int sample, int delete, struct asrState &state) {
    int index = state.wr;
    int h = 0;
    unsigned l = 0;
    state.buffer[index] = sample;
    index++;
    if (index >= ASR_ARRAY) {
        index = 0;
    }
    state.wr = index;
    if(delete) {
        state.insertIndex = ASR_ORDER;
        return 0;
    }
    if(state.insertIndex < 0) {
        int rd = index - (ASR_ARRAY>>1) - 1;
        if (rd < 0) {
            rd += ASR_ARRAY;
        }
        return state.buffer[rd];
    }

    for(int i = 0, rd = state.wr; i < ASR_ORDER; i++) {
        {h,l} = macs(coeff[state.insertIndex + ASR_ORDER * i], state.buffer[rd], h, l);
        rd++;
        if (rd >= ASR_ARRAY) {
            rd -= ASR_ARRAY;
        }
    }
    state.insertIndex--;
    h = h << 11 | l >> 21;
    if (state.insertIndex == ASR_ORDER) {
        state.insertIndex = -1;
    }
    return h;
}
