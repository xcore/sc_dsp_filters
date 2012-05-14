#include <stdio.h>
#include <xs1.h>
#include <print.h>
#include "asrc.h"

int sineWave[48] = {
    0,
    2189866,
    4342263,
    6420362,
    8388607,
    10213321,
    11863283,
    13310260,
    14529495,
    15500126,
    16205546,
    16633684,
    16777216,
    16633684,
    16205546,
    15500126,
    14529495,
    13310260,
    11863283,
    10213321,
    8388608,
    6420362,
    4342263,
    2189866,
    0,
    -2189866,
    -4342263,
    -6420362,
    -8388607,
    -10213321,
    -11863283,
    -13310260,
    -14529495,
    -15500126,
    -16205546,
    -16633684,
    -16777216,
    -16633684,
    -16205546,
    -15500126,
    -14529495,
    -13310260,
    -11863283,
    -10213321,
    -8388608,
    -6420362,
    -4342263,
    -2189866,
};


int ar[100];

int main(void) {
    struct asrcState asrcState;
    int cntr = 0;
    int ok = 0;
    timer t;
    int t0, t1;

    asrcInit(asrcState);
    t :> t0;
    for(int i = 0; i < 481 + (ASRC_ORDER>>1); i++) {
        int d = sineWave[cntr%48];
        int k;
        int deleteOne = i == 13;
        int insertOne = 0;//i == 13; 
        
        k = asrcFilter(d, deleteOne?-1:insertOne?+1:0, asrcState);
//        ar[w++] = d;
        if (!deleteOne && i > (ASRC_ORDER>>1)) {
            t :> t1;
            t1 -= t0;
//            printintln(t1);
//            printstr(" ");
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
