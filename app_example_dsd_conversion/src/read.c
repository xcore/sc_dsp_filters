#include <stdio.h>
#include <xclib.h>

static FILE *fin = NULL;
static int fd;

void read_bytes(int array[], int index, int bits) {
    int lefthalf = 1;
    if (fin == NULL) {
        fin = fopen("/Users/henk/gitCommunity/sc_dsp_filters/app_example_dsd_conversion/DSD-test-tone-PCM-packed-std-v1.wav", "rb");
//        printf("%08x\n", fin);
//        fd = open("/Users/henk/gitCommunity/sc_dsp_filters/app_example_dsd_conversion/DSD-test-tone-PCM-packed-std-v1.wav", "rb");
//        printf("%08x\n", fd);
      
        fseek(fin, 70, SEEK_SET);
        fin = fopen("/Users/henk/gitCommunity/sc_dsp_filters/app_example_dsd_conversion/dat","rb");
    }
    for(int n = 0; n < bits; n += 16) {
        char s[6];
        int data;
        fread(s, 6, 1, fin);
        data = s[1] << 0 | s[2] << 8;
        if (lefthalf) {
            data = data << 16;
        }
        lefthalf = !lefthalf;
        array[index] |= data;
//        printf("%04x ", data);
        if (lefthalf) {
            array[index] = bitrev(array[index]);
            index++;
        }
    }
}
