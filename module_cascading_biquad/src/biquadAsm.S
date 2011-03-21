#include "coeffs.h"

#define NWORDS 8

 //   .cc_top biquadAsm, biquadAsm.func
    
    .globl biquadAsm
    .globl biquadAsm.nntackwords
    .linkset biquadAsm.nntackwords,NWORDS
    
biquadAsm:
    entsp NWORDS
    stw   r4, sp[0]
    stw   r5, sp[1]
    stw   r6, sp[2]
    stw   r7, sp[3]
    stw   r8, sp[4]
    stw   r9, sp[5]
    stw   r10, sp[6]

    // r0: xn
    // r1: &state.xn12dbs[j]
    // r2: state.xn1[j]
    // r3: state.xn2[j]
    // r4: tmp
    // r5: FRACTIONALBITS
    // r6: 1<<(FRACTIONALBITS-1)
    // r7: &coeffs[0][j]
    // r8: j
    // r9: &coeffs[state.dbs[j]][j]
    // r10: ynl
    // r11: ynh

    ldc   r5, FRACTIONALBITS
    ldaw  r7, dp[biquads]
    ldc   r8, 0

    ldw   r2, r1[0]
    ldw   r3, r1[1]

    ldc   r11, 0
    ldc   r6, 1
    shl   r6, r6, r5
    shr   r6, r6, 1
    
loop:
    ldc   r4, 5*BANKS       // words per filter * BANKS
    ldw   r9, r1[2]
    or    r10, r6, r6
    mul   r4, r4, r9
    ldaw  r9, r7[r4]

    ldw   r4, r9[0]
    maccs r11, r10, r4, r0
    ldw   r4, r9[1]
    maccs r11, r10, r4, r2
    ldw   r4, r9[2]
    maccs r11, r10, r4, r3

    stw   r2, r1[1]
    stw   r0, r1[0]
    ldaw  r1, r1[3]

    ldw   r4, r9[3]
    ldw   r2, r1[0]
    maccs r11, r10, r4, r2
    ldw   r4, r9[4]
    ldw   r3, r1[1]
    maccs r11, r10, r4, r3

    ldaw  r7, r7[5]           // Words per filter

    or    r4, r11, r11
    sext  r4, r5
    eq    r4, r11, r4
    bt    r4, resultFits
    ldc   r0, 0x80
    shl   r0, r0, 24
    lsu   r4, r11, r4
    sub   r0, r0, r4
    bu    resultDone

resultFits:
    ldc  r4, 32-FRACTIONALBITS
    shl  r11, r11, r4
    shr  r10, r10, r5
    or   r0, r11, r10

resultDone: 
    add  r8, r8, 1
    eq   r11, r8, BANKS
    bf   r11, loop                  // clears r11

    stw   r2, r1[1]
    stw   r0, r1[0]

    ldc   r11, 3*BANKS
    ldaw  r9, r1[-r11]
    ldc   r11, 3
    ldaw  r1, r1[r11]
    ldw   r11, r1[0]
    bt    r11, decrementDelay
    ldc   r11, 40
    stw   r11, r1[0]
    ldw   r11, r1[1]
    sub   r11, r11, 1
    stw   r11, r1[1]
    bt    r11, checkdB
    ldc   r4, BANKS
    stw   r4, r1[1]
checkdB:   
    ldc   r10, 3        //r9 poinst to db/xn1/xn2, r1 points to adjustdelay, counter, desdb[]
    mul   r10, r11, r10
    ldaw  r9, r9[r10]
    ldw   r10, r9[2]
    add   r11, r11, 2
    ldw   r8, r1[r11]
magicLabel:
    lsu   r7, r8, r10
    bt    r7, decrement
    lsu   r7, r10, r8
    bf    r7, allDone
    add   r10, r10, 1
    stw   r10, r9[2]
    bu    allDone
decrement:
    sub   r10, r10, 1
    stw   r10, r9[2]
    bu    allDone

decrementDelay:
    sub   r11, r11, 1
    stw   r11, r1[0]
allDone:    
        
    ldw   r4, sp[0]
    ldw   r5, sp[1]
    ldw   r6, sp[2]
    ldw   r7, sp[3]
    ldw   r8, sp[4]
    ldw   r9, sp[5]
    ldw   r10, sp[6]
    retsp NWORDS

//    .cc_bottom biquadAsm.func