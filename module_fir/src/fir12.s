	.set fir12.locnochandec, 1
	.text
	.globl	fir12
	.cc_top fir12.function
	.align	4
fir12:
	entsp 7
	stw r4, sp[2]
	stw r10, sp[3]
    ldc r4, 0
	stw r5, sp[1]
	stw r6, sp[4]
    ladd r11, r10, r4, r4, r4
	stw r7, sp[6]
	stw r8, sp[5]

loop:
	ldaw r5, r1[r2]
    ldaw r2, r2[3]
	ldaw r6, r0[r4]
	ldw r7, r6[0]
	ldw r8, r5[0]
	maccs r10, r11, r7, r8
	ldw r7, r6[1]
	ldw r8, r5[1]
	maccs r10, r11, r7, r8
	ldw r7, r6[2]
	ldw r8, r5[2]
	maccs r10, r11, r7, r8
	ldw r7, r6[3]
	ldw r8, r5[3]
	maccs r10, r11, r7, r8
	ldw r7, r6[4]
	ldw r8, r5[4]
	maccs r10, r11, r7, r8
	ldw r7, r6[5]
	ldw r8, r5[5]
	maccs r10, r11, r7, r8
	ldw r7, r6[6]
	ldw r8, r5[6]
    ldaw r4, r4[3]
	maccs r10, r11, r7, r8
	ldw r7, r6[7]
	ldw r8, r5[7]
	maccs r10, r11, r7, r8
	ldw r7, r6[8]
	ldw r8, r5[8]
	maccs r10, r11, r7, r8
	ldw r7, r6[9]
	ldw r8, r5[9]
	maccs r10, r11, r7, r8
	ldw r7, r6[10]
	ldw r8, r5[10]
	maccs r10, r11, r7, r8
	ldw r7, r6[11]
	ldw r8, r5[11]
	maccs r10, r11, r7, r8

	lss r6, r2, r3
    bt r6, skip
	sub r2, r2, r3
skip:

	lss r6, r4, r3
	bt r6, loop

	ldw r5, sp[1]
	ldw r4, sp[2]
    mov r1, r10
	ldw r10, sp[3]
	ldw r8, sp[5]
    mov r0, r11
	ldw r7, sp[6]
	ldw r6, sp[4]
	retsp 7
	.cc_bottom fir12.function
	.set	fir12.nstackwords,7
	.globl	fir12.nstackwords
	.set	fir12.maxcores,1
	.globl	fir12.maxcores
	.set	fir12.maxtimers,1
	.globl	fir12.maxtimers
	.set	fir12.maxchanends,0
	.globl	fir12.maxchanends
.fir12end:
	.size	fir12, .fir12end-fir12


