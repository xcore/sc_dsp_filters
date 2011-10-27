// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

//extern void firASM_DoubleData_multiThread(streaming chanend c, int H[],int X[], unsigned size);

#define NWORDS 7
    .globl firASM_DoubleData_multiThread
    .globl firASM_DoubleData_multiThread.nstackwords
    .linkset firASM_DoubleData_multiThread.nstackwords,NWORDS

#define c		r0
#define H		r1
#define X		r2
#define size	r3
#define x		r4
#define h	 	r5
#define Xoff	r6
#define i 		r7
#define state 	r8
#define Xm  	r9
#define ynl 	r10
#define ynh 	r11

firASM_DoubleData_multiThread:
    entsp NWORDS
    stw   r4, sp[0]
    stw   r5, sp[1]
    stw   r6, sp[2]
    stw   r7, sp[3]
    stw   r8, sp[4]
    stw   r9, sp[5]
    stw   r10, sp[6]

mainloop:
add i,size,0  //reset i to sizeof vector
testct r10,res[c]
bt r10, allDone
in state,res[c] // in state
//sub state,state,1
ldaw Xoff,X[state];  //change ??
ldc ynl,0 //reset MAC
ldc ynh,0 //reset MAC
bu entrypoint

.align 4
subloop:
maccs ynh,ynl,h,x
entrypoint:
ldw x,Xoff[i] //Xoffset = X-1*int32
sub i,i,1
ldw h,H[i]
bt i,subloop
maccs ynh,ynl,h,x
out res[c],ynl
out res[c],ynh
bu mainloop

allDone:                          // Now just restore all registers.
    inct  r4, res[c];
    ldw   r4, sp[0]
    ldw   r5, sp[1]
    ldw   r6, sp[2]
    ldw   r7, sp[3]
    ldw   r8, sp[4]
    ldw   r9, sp[5]
    ldw   r10, sp[6]
    retsp NWORDS

//    .cc_bottom firASM_DoubleData_multiThread.func
