//Generated code - do not edit.

#define BANKS 2
#define DBS 41
#define FRACTIONALBITS 27
#ifdef __XC__
extern struct coeff {int b0, b1, b2, a1, a2;} biquads[DBS][BANKS];

typedef struct {
    struct {int xn1; int xn2; int db;} b[BANKS+1];
    int adjustDelay;
    int adjustCounter;
    int desiredDb[BANKS];
} biquadState;

extern void initBiquads(biquadState &state, int zeroDb);
extern int biquadCascade(biquadState &state, int sample);
#endif
