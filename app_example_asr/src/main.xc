#include <stdio.h>
#include "asr.h"

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
    struct asrState asrState;
    int cntr = 45;
    asrInit(asrState);
    for(int i = 0; i < 28; i++) {
        int d = sineWave[i%48];
        int k;
        int deleteOne = i == 16;
        k = asrDelete(d, deleteOne, asrState);
        if (!deleteOne) {
            printf("%2d %9d %9d %9d\n", i, sineWave[(i+44)%48], sineWave[(cntr++)%48], k);
        }
    }
    return 0;
}

//::twoexample
// This example is untested... Ought to be...
void twoStreamExample(chanend inX, chanend inY, chanend outX, chanend outY) {
    struct asrState asrStateX, asrStateY;
    int sample;
    asrInit(asrStateX);
    asrInit(asrStateY);
    while(1) {
        select {
        case inX :> sample:
            diff++;
            if (diff > 10) {
                deleteOne = 1;
                diff--;
            }
            v = asrDelete(sample, deleteOne, asrStateX);
            if (!deleteOne) {
                outX <: v;
            }
            break;
        case inY :> sample:
            diff--;
            if (diff < -10) {
                deleteOne = 1;
                diff++;
            }
            v = asrDelete(sample, deleteOne, asrStateY);
            if (!deleteOne) {
                outY <: v;
            }
            break;
        }
    }
}
//::
