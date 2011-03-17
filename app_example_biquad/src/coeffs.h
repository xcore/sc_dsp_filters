//Generated code - do not edit.

#define BANKS 2
#define DBS 41
extern struct coeff {int a1, a2, b0, b1, b2;} biquads[DBS][BANKS];

typedef struct {
    int xn1[BANKS+1], xn2[BANKS+1];
    int db[BANKS];
    int desiredDb[BANKS];
    int adjustCounter;
    int adjustDelay;
} biquadState;

extern void initBiquads(biquadState &state, int zeroDb);
extern int biquadCascade(biquadState &state, int sample);
