#include <stdio.h>

FILE *fout, *fin;

void writeinit() {
    fout = fopen("/Users/henk/AAAA.AUDIO", "wb");
    fin = fopen("/Users/henk/AAAB.AUDIO", "wb");
}

void writeme(int i, int i2, int i3, int i4) {
    fwrite(&i, 1, 4, fout);
    fwrite(&i2, 1, 4, fout);
    fwrite(&i3, 1, 4, fout);
    fwrite(&i4, 1, 4, fout);
    fwrite(&i2, 1, 4, fin);
}
