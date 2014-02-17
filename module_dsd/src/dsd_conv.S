
    
	.cc_top dsd_convert.function
.globl dsd_convert
    .align 4
dsd_convert:
	entsp 7

	stw r10, sp[0]
	ldc  r10, 16

	stw r5, sp[5]
	add r5, r0, 0

	stw r6, sp[4]
    ldc  r6, 0

	stw r7, sp[3]
    ldc r0, 0
    
	stw r8, sp[2]
	sub  r8, r1, 1                 // Mask in r8

	stw r9, sp[1]

loop:
	sub  r1, r1, 1
    add  r11, r1, r3
    and  r11, r11, r8
	ldw  r7, r2[r11]

	lmul r11, r7, r7, r10, r6, r6
	ldw  r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[r10]

	lmul r11, r7, r7, r10, r6, r6
	ldw  r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[r10]

	lmul r11, r7, r7, r10, r6, r6
	ldw  r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[r10]

	lmul r11, r7, r7, r10, r6, r6
	ldw  r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[r10]

	lmul r11, r7, r7, r10, r6, r6
	ldw  r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[r10]

	lmul r11, r7, r7, r10, r6, r6
	ldw  r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[r10]

	lmul r11, r7, r7, r10, r6, r6
	ldw  r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[r10]

	lmul r11, r7, r7, r10, r6, r6
	ldw  r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[r10]
        
  	bt   r1, loop

	ldw r10, sp[0]
	ldw r9, sp[1]
	ldw r8, sp[2]
	ldw r7, sp[3]
	ldw r6, sp[4]
	ldw r5, sp[5]
	retsp 7
	.cc_bottom dsd_convert.function
	.set	dsd_convert.nstackwords,7
	.globl	dsd_convert.nstackwords
	.set	dsd_convert.maxcores,1
	.globl	dsd_convert.maxcores
	.set	dsd_convert.maxtimers,0
	.globl	dsd_convert.maxtimers
	.set	dsd_convert.maxchanends,0
	.globl	dsd_convert.maxchanends




    
	.cc_top dsd_convert_16.function
.globl dsd_convert_16
    .align 4
dsd_convert_16:
	entsp 7

	stw r10, sp[0]
	ldc  r10, 16

	stw r5, sp[5]
    add  r5, r0, 0

	stw r6, sp[4]
    ldc  r6, 0

	stw r7, sp[3]
    ldc r0, 0
    
	stw r8, sp[2]
	sub  r8, r1, 1                 // Mask in r8

	stw r9, sp[1]

loop2:
	sub  r1, r1, 1
    add  r11, r1, r3
    and  r11, r11, r8
	ldw  r7, r2[r11]

	lmul r11, r7, r7, r10, r6, r6
	ld16s r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[8]

	lmul r11, r7, r7, r10, r6, r6
	ld16s r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[8]

	lmul r11, r7, r7, r10, r6, r6
	ld16s r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[8]

	lmul r11, r7, r7, r10, r6, r6
	ld16s r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[8]

	lmul r11, r7, r7, r10, r6, r6
	ld16s r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[8]

	lmul r11, r7, r7, r10, r6, r6
	ld16s r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[8]

	lmul r11, r7, r7, r10, r6, r6
	ld16s r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[8]

	lmul r11, r7, r7, r10, r6, r6
	ld16s r9, r5[r11]
	add  r0, r0, r9
	ldaw r5, r5[8]
        
  	bt   r1, loop2

    ld16s r9, r5[r1]
    mul r0, r0, r9

	ldw r10, sp[0]
	ldw r9, sp[1]
	ldw r8, sp[2]
	ldw r7, sp[3]
	ldw r6, sp[4]
	ldw r5, sp[5]
	retsp 7
	.cc_bottom dsd_convert_16.function
	.set	dsd_convert_16.nstackwords,7
	.globl	dsd_convert_16.nstackwords
	.set	dsd_convert_16.maxcores,1
	.globl	dsd_convert_16.maxcores
	.set	dsd_convert_16.maxtimers,0
	.globl	dsd_convert_16.maxtimers
	.set	dsd_convert_16.maxchanends,0
	.globl	dsd_convert_16.maxchanends
