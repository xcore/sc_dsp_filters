#include <stdio.h>

extern int table[];
extern int dsd[];

#pragma unsafe arrays
int x(int sum, int N) {
  int offset = 0;
  do {
    N--;
    unsigned int d = dsd[N];
#pragma loop unroll
    for(unsigned int j = 0; j < 8; j ++) {
      sum += table[offset + (d&15)];
      offset += 16;
      d >>= 4;
    }
  } while (N != 0);
  return sum;
}

