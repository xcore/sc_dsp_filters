#include <stdio.h>
#include <xs1.h>
#include <print.h>
#include "asrc.h"

int sineWave[48] = {
    0,
    2189866,
    4342263,
    6420363,
    8388608,
    10213322,
    11863283,
    13310260,
    14529495,
    15500126,
    16205546,
    16633685,
    16777216,
    16633685,
    16205546,
    15500126,
    14529495,
    13310260,
    11863283,
    10213322,
    8388608,
    6420363,
    4342263,
    2189866,
    0,
    -2189866,
    -4342263,
    -6420363,
    -8388608,
    -10213322,
    -11863283,
    -13310260,
    -14529495,
    -15500126,
    -16205546,
    -16633685,
    -16777216,
    -16633685,
    -16205546,
    -15500126,
    -14529495,
    -13310260,
    -11863283,
    -10213322,
    -8388608,
    -6420363,
    -4342263,
    -2189866,
};


int ar[100];

int delete_main(void) {
    struct asrcState asrcState;
    int cntr = 0;
    timer t;
    int t0, t1;
    int offset = ASRC_ORDER>>1;
    int total = 9601;

    asrcInit(asrcState);
    t :> t0;
    for(int i = 0; i < total + offset; i++) {
        int d = sineWave[cntr%48];
        int k;
        int deleteOne = i == 13;
        int insertOne = 0;//i == 13; 
        
        k = asrcFilter(d, deleteOne?-1:insertOne?+1:0, asrcState);
        if (!deleteOne && i > offset) {
            t :> t1;
            t1 -= t0;
            printintln(k);
            t :> t0;
        }
        if (deleteOne) {
            cntr ++;
        } else if (insertOne) {
            ;
        } else {
            cntr ++;
        }
    }
    return 0;
}

int continuous_main(void) {
    struct asrcState asrcState;
    int cntr = 0;
    timer t;
    int t0, t1;
    int total = 9600;
    int offset = ASRC_ORDER>>1;

    asrcInit(asrcState);
    t :> t0;
    for(int i = 0; i < total + offset + 2; i++) {
        int d = sineWave[cntr%48];
        int k;
        int fraction;
        if (i > offset) {
            fraction = ASRC_UPSAMPLING * (i - offset) / total;
        } else {
            fraction = 0;
        }

        asrcContinuousBuffer(d, asrcState);
        k = asrcContinuousInterpolate(fraction, asrcState);
        if (i > offset) {
            t :> t1;
            t1 -= t0;
//            printintln(t1);
//            printstr(" ");
            printintln(k);
            t :> t0;
        }
        cntr ++;
    }
    return 0;
}

int main(void) {
#ifdef TEST_CONTINUOUS
    continuous_main();
#else
    delete_main();
#endif
    return 0;
}

//::twoexample
#define MAXDIST 4

// This example is untested... Ought to be...
void twoStreamExample(chanend inMaster, chanend inSlave, chanend outMaster, chanend outSlave) {
    struct asrcState asrcState;
    int sample, v;
    int diff = 0;
    asrcInit(asrcState);
    while(1) {
        select {
        case inMaster :> sample:
            outMaster <: v;
            if (diff > MAXDIST) {                   // Difference too large - add a sample in other stream.
                v = asrcFilter(0, 1, asrcState);
                outSlave <: v;
            } else {
                diff++;
            }
            break;
        case inSlave :> sample:
            if (diff < -MAXDIST) {                  // Difference too large - remove a sample in this stream.
                (void) asrcFilter(sample, -1, asrcState);
            } else {
                v = asrcFilter(sample, 0, asrcState);
                outSlave <: v;
                diff--;
            }
            break;
        }
    }
}
//::

//::reclockexample
#define MAXDIFF 4

// This example is untested... Ought to be...
void reclockExample(port inLRclk, chanend inSlave, chanend outSlave) {
    struct asrcState asrcState;
    int sample, v;
    int diff = 0;
    int lr = 0;
    asrcInit(asrcState);
    while(1) {
        select {
        case inLRclk when pinsneq(lr) :> lr:
            if (lr) {
                if (diff > MAXDIFF) {                   // Difference too large - add a sample in other stream.
                    v = asrcFilter(0, 1, asrcState);
                    outSlave <: v;
                } else {
                    diff++;
                }
            }
            break;
        case inSlave :> sample:
            if (diff < -MAXDIFF) {                     // Difference too large - remove a sample in this stream.
                (void) asrcFilter(sample, -1, asrcState);
            } else {
                v = asrcFilter(sample, 0, asrcState);
                outSlave <: v;
                diff--;
            }
            break;
        }
    }
}
//::
