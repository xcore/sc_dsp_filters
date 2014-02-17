#include <stdio.h>
#include <stdlib.h>
#include <dsd_conv.h>
#include <xclib.h>
#include <xs1.h>

#define COEFF_COMPRESSION_16 2046

#define FREQ (2816)

#define BITS_IN_WINDOW 1025                      // must be power of 2 + 1
#define WORDS_IN_WINDOW ((BITS_IN_WINDOW-1)/32)

int dsd[WORDS_IN_WINDOW];
int dsd_half[WORDS_IN_WINDOW/2];

extern int p(int,int);
extern int dsd_convert_xc(int,int,int);
extern void writeme(int i, int i2, int , int);
extern void writeinit();

extern int coeff[];
//extern int coeff_compressed[];
//extern short coeff_compressed_16[];

extern int mySine[FREQ];

int check(int signal[], int offset) {
    int sum = 0;
    int four = 0;
    int cnt = 0;
    int word;// = signal[256/32];
    // final coefficient is always 0, ignore the Nth element.
    for(int i = 0; i < WORDS_IN_WINDOW; i++) {
        word = signal[(i + offset) % WORDS_IN_WINDOW];
        for(int j = 0; j < 32; j++) {
            int bit = word & 1;
            if (cnt == 0) {
//                printf("Bits %01x ", word & 0xF);
            }
            word >>= 1;
            if (bit) {
                four += coeff[i*32 + j];
             //   printf("+ %d\n", coeff[i*32+j]);
            } else {
                four -= coeff[i*32 + j];
             //   printf("- %d\n", coeff[i*32+j]);
            }
            if (++cnt == 4) {
//                printf("         %d\n", four);
                sum += four;
                four = 0;
                cnt = 0;
            }
        }
    }
    return sum;
}

extern void read_bytes(int array[], int index, int bits);

void mmain() {
  timer t;
  int xx, yy, i, chk0, chk1, chk2, chk3;
  int error = 0;
  int t1025_16, t1025_32;
  int t513_16, t513_32;

  writeinit();

  int index_mod = 0;
  for(int k = 0; k < 441*40*64 + WORDS_IN_WINDOW*64; k += 64) {
//      int index = k/32;
      dsd[index_mod] = 0;
      dsd[index_mod+1] = 0;
      read_bytes(dsd, index_mod, 64);
//      attenuate(dsd, index_mod, 2);
      index_mod += 2;
      if (index_mod >= WORDS_IN_WINDOW) {
          index_mod = 0;
      }
      for(int i = WORDS_IN_WINDOW/2; i < WORDS_IN_WINDOW; i++) {
          dsd_half[(i+index_mod)%(WORDS_IN_WINDOW/2)] = dsd[(i+index_mod)%WORDS_IN_WINDOW];
      }

      t :> xx;
      chk0 = dsd_convert(coeff_compressed_1025_32, 32, dsd, index_mod);
      t :> yy;
      t1025_32 = yy-xx;

/*      t :> xx;
      chk1 = dsd_convert_16(coeff_compressed_1025_16, 32, dsd, index_mod);
      t :> yy;
      t1025_16 = yy-xx;

      t :> xx;
      chk2 = dsd_convert(coeff_compressed_513_32, 16, dsd_half, index_mod);
      t :> yy;
      t513_32 = yy-xx;

      t :> xx;
      chk3 = dsd_convert_16(coeff_compressed_513_16, 16, dsd_half, index_mod);
      t :> yy;
      t513_16 = yy-xx;
*/
/*
      printf("%08x %11d %6d %11d %6d times 513/1025 %d %d %d %d rates 513/1025: %d %d\n", chk0, chk0, chk1-chk0, chk2, chk3-chk2, t513_16, t513_32, t1025_16, t1025_32, 100000000/t513_32, 100000000/t1025_32);
*/

      if (k % 1000 == 0) printf("%d\n", k);
      if (k >= WORDS_IN_WINDOW*64) {
          writeme(chk0, chk1, chk2, chk3);
      }

  }
  exit(0);
}

int main() {
  par {
    mmain();
  }
  return 0;
}
