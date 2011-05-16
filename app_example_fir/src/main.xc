// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <stdio.h>
#include <print.h>
#include "fir.h"

int coeffs[3] = {
    0x01000000, //1
    0x02000000, //2
    0x03000000, //3
};

int state[3];

int main() {
    printintln(fir(0, coeffs, state,3));
    printintln(fir(1, coeffs, state,3));
    printintln(fir(2, coeffs, state,3));
    printintln(fir(3, coeffs, state,3));
    return 0;
}
