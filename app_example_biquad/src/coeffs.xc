//Generated code - do not edit.

// First index is the dbLevel, in steps of 1.0 db, first entry is 8.0 db
// Second index is the filter number - this filter has 2 banks
// Each structure instantiation contains the five coefficients for each biquad:
// b0/a0, b1/a0, b2/a0, -a1/a0, -a2/a0; all numbers are stored in 2.30 fixed point
#include "src/coeffs.h"
#include "biquadCascade.h"
struct coeff biquads[DBS][BANKS] = {
  { //Db: 8.0
    {275822368, -511098436, 238058741, 511935872, -244608218},
    {656221226, -1251485889, 597972812, 497410498, -231683192},
  },
};
