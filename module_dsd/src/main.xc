#include <stdio.h>
#include <stdlib.h>

#define N 1600

int table[N/32*16*8];
int dsd[N/32];

extern int z(int,int);
extern int p(int,int);
extern int q(int,int);
extern int x(int,int);

void mmain() {
  timer t;
  int xx, yy, i;
  printf("Overheads: %d byte table, %d byte dsd buffer\n", N/32*16*8*4, N/32*4);
  for(int k = 0; k < N/32; k++) {
     dsd[k] = k*k*k*k*k;
  }
  for(int k = 0; k < N/32*16*8; k++) {
     table[k] = k^251;
  }
  t :> xx;
  i = x(0,N/32);
  t :> yy;
  printf("Y: %d  %d %d\n", i, yy - xx, 100000000/(yy-xx));
  t :> xx;
  i = z(0,N/32);
  t :> yy;
  printf("Z: %d  %d %d\n", i, yy - xx, 100000000/(yy-xx));
  t :> xx;
  i = p(0,N/32);
  t :> yy;
  printf("P: %d  %d %d\n", i, yy - xx, 100000000/(yy-xx));
  t :> xx;
  i = q(0,N/32);
  t :> yy;
  printf("Q: %d  %d %d\n", i, yy - xx, 100000000/(yy-xx));
  exit(0);
}

int main() {
  par {
    while(1);
    while(1);
    while(1);
    while(1);
    mmain();
  }
  return 0;
}
