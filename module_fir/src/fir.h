// Copyright (c) 2011, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#define CORES 3

#define LDAW(ptrout,ptrin,offset) asm("ldaw %0,%1[%2]": "=r"(ptrout) : "r"(ptrin) ,"r"(offset))
#define CAST(ptrout,ptrin) asm("add %0,%1,0": "=r"(ptrout):"r"(ptrin))


int fir(int xn, int coeffs[], int state[], int ELEMENTS);
extern int firAsm(int xn, int coeffs[], int state[], int ELEMENTS);
extern void firASM_DoubleData_multiThread(streaming chanend c, int hPtr,int xPtr, unsigned size);
extern void firASM_DoubleData_singleThread(streaming chanend c, int H[],int X[], unsigned size);
int fir_Multithreading2(streaming chanend c, int h[],int x[],unsigned ntaps);
int fir_Multithreading3(streaming chanend c, int h[],int x[],unsigned ntaps);
int fir_Multithreading4(streaming chanend c, int h[],int x[],unsigned ntaps);
int fir_MultiCore(streaming chanend c,streaming chanend cdc[]);
void disconnect(streaming chanend c[], unsigned size);
