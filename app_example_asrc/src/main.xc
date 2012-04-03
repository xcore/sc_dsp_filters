#include <stdio.h>
#include <xs1.h>
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

int main(void) {
    struct asrcState asrcState;
    int cntr = 0;
    int fdiff, ofdiff = 0;
    int sdiff, osdiff = 0, tdiff;
    int ok = 0;
    timer t;
    int t0, t1;
    asrcInit(asrcState);
    printf("Nm     Input Difference   Output FrstDiff ScndDiff ThrdDiff Time(us)\n");
    for(int i = 0; i < 33; i++) {
        int d = sineWave[cntr%48];
        int k;
        int deleteOne = i == 12;
        int insertOne = i == 24;
        t :> t0;
        k = asrcFilter(d, deleteOne?-1:insertOne?+1:0, asrcState);
        t :> t1;
        t1 -= t0;
        if (!deleteOne) {
            fdiff = ok - k;
            ok = k;
            sdiff = fdiff - ofdiff;
            ofdiff = fdiff;
            tdiff = osdiff - sdiff;
            osdiff = sdiff;
            printf("%2d %9d %9d %9d %8d %8d %8d %3d.%03d\n", i, sineWave[(cntr+43)%48], sineWave[(cntr+43)%48]-k, k, fdiff, sdiff, tdiff, t1/100, (t1%100)*10);
        } else {
            printf("%2d                                                          %3d.%03d\n", i, t1/100, (t1%100)*10);
        }
        if (deleteOne) {
            cntr += 2;
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
