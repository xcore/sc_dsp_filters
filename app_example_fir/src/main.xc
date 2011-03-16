// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <stdio.h>
#include <print.h>
#include "fir.h"

int coeffs[3] = {
    0x400000, //0.25
    0x800000, //0.5
    0x400000, //0.25
};

int state[3];

int main() {
    int i = 0x01000000;
    printintln(fir(0, coeffs, state,3));
    printintln(fir(0, coeffs, state,3));
    printintln(fir(0, coeffs, state,3));
    printintln(fir(i, coeffs, state,3));
    printintln(fir(i, coeffs, state,3));
    printintln(fir(i, coeffs, state,3));
    printintln(fir(i, coeffs, state,3));
    return 0;
}
