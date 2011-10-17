// Copyright (c) 2011, Mikael Bohman, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

//extern void firASM_DoubleData_singleThread(streaming chanend c, int H[],int X[], unsigned size);

#define NWORDS 7
    .globl firASM_DoubleData_singleThread
    .globl firASM_DoubleData_singleThread.nstackwords
    .linkset firASM_DoubleData_singleThread.nstackwords,NWORDS

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

firASM_DoubleData_singleThread:
    entsp NWORDS
    stw   r4, sp[0]
    stw   r5, sp[1]
    stw   r6, sp[2]
    stw   r7, sp[3]
    stw   r8, sp[4]
	ldc state,0
    stw   r9, sp[5]
	ldaw Xm,X[size]
    stw   r10, sp[6]


mainloop:
add i,size,0  //reset i to sizeof vector
testct r10,res[c]
bt r10, allDone
in x,res[c]
stw x,X[state] // store word in X[state]
add r10,state,size
stw x,X[r10]   // store word in X[state+size]
bf state,update  //if state==0{state+=size}
updateR:
sub state,state,1

XoffupdateR:
ldc ynl,0 //reset MAC
ldc ynh,0 //reset MAC
bu entrypoint

update:
add state,state,size
ldaw Xoff,Xm[-1];
bu updateR

.align 4
subloop:
maccs ynh,ynl,h,x
entrypoint:
ldw x,Xoff[i] //Xoffset = X-1*int32
sub i,i,1
ldw h,H[i]
bt i,subloop
maccs ynh,ynl,h,x
shl ynh,ynh,8
shr ynl,ynl,24
or  ynh,ynh,ynl
out res[c],ynh
ldaw Xoff,Xoff[-1];
bu mainloop

allDone:                          // Now just restore all registers and receive control tokens.
    inct  r4, res[c];
    ldw   r4, sp[0]
    ldw   r5, sp[1]
    ldw   r6, sp[2]
    ldw   r7, sp[3]
    ldw   r8, sp[4]
    ldw   r9, sp[5]
    ldw   r10, sp[6]
    retsp NWORDS

//    .cc_bottom firASM_DoubleData_singleThread.func
