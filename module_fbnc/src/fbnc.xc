#include <xclib.h>
#include <xs1.h>
#include <stdio.h>
#include "fbnc.h"
#include "fbnc_conf.h"

#define INPUTBITS  16
#define MAX     ((1<<((INPUTBITS)-1))-1)
#define MIN     (-(1<<((INPUTBITS)-1)))
#define SHIFT   (32-(INPUTBITS))

static int microphoneInput[FILTERSIZE];
static long long Pm;
static int speakerOutput[FILTERSIZE + OFFSET + 1];
static int fcnt = 0;
int fbnc_coefficients[FILTERSIZE];
int fbnc_diff[FILTERSIZE];
unsigned long long divider64;
unsigned int leadingZeroes;
int divider32;
int corr;

int feedbackSuppression(int input, int oneOverMu) {
    long long rHat;
    int output;
    
    input >>= SHIFT;

#if 0
    Pm -= microphoneInput[fcnt] * (long long) microphoneInput[fcnt];
    microphoneInput[fcnt] = input;
    Pm += microphoneInput[fcnt] * (long long) microphoneInput[fcnt];

    fcnt++;
    if (fcnt == FILTERSIZE) {
        fcnt = 0;
    }
#else
    Pm -= speakerOutput[FILTERSIZE+OFFSET] * (long long) speakerOutput[FILTERSIZE+OFFSET];
    Pm += speakerOutput[FILTERSIZE] * (long long) speakerOutput[FILTERSIZE];
#endif


    rHat = 0;
    for(int k = 0; k < FILTERSIZE; k++) {
        rHat += fbnc_coefficients[k] * (long long) speakerOutput[k+OFFSET];
    }

    // rHat is an approximation of the echos
    // Based on the filter coefficients            fbnc_coefficients[        0 .. FILTERSIZE          ]
    // and the values that we placed on the speaker [ n-OFFSET .. n-OFFSET-FILTERSIZE ]

    output = input - (rHat >> 24);

    if (output > MAX) {
        output = MAX;
    } else if (output < MIN) {
        output = MIN;
    }

    speakerOutput[0] = output; 
    // speakerOutput is corrected microphoneInput

    if (Pm > 1) {
        divider64 = Pm * oneOverMu;
        leadingZeroes = clz((unsigned) (divider64>>32));
        divider32 = divider64 >> (33-leadingZeroes);    // Pm / 2^32
        corr = (((long long) output) << (leadingZeroes)) / divider32; // 0.32
        if (divider32 < 0) {
            printf("Div32: %d\n");
        }
        for(int k = 0; k < FILTERSIZE; k++) {
            fbnc_diff[k] =  ((speakerOutput[k+OFFSET] * (long long)corr) >> 9);
            fbnc_coefficients[k] = (fbnc_coefficients[k]) + fbnc_diff[k];
//          8.24 = 8.24 +  32.0                      * 1.31;
        }
    }
    for(int k = FILTERSIZE+OFFSET; k != 0; k--) {
        speakerOutput[k] = speakerOutput[k-1] ;
    }

    return output << SHIFT;
}


void fbnc_print(void) {
    for(int k = 0; k < FILTERSIZE; k++) {
        int x = fbnc_coefficients[k];
        if (x < 0) {
            printf("-");
            x = -x;
        } else {
            printf(" ");
        }
        printf("%d.%09d\n", x >> 24, ((x & 0x00ffffff)>>4) * 953);
    }
}
