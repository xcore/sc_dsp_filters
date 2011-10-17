// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/**
 **/

extern int fir(int xn, int coeffs[], int state[], int ELEMENTS);
extern int firAsm(int xn, int coeffs[], int state[], int ELEMENTS);
extern void firASM_DoubleData_singleThread(streaming chanend c, int H[],int X[], unsigned size);
