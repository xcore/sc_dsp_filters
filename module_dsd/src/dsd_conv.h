extern short coeff_compressed_513_16[2049];
extern int   coeff_compressed_513_32[2048];
extern short coeff_compressed_1025_16[4097];
extern int   coeff_compressed_1025_32[4096];

/**
 * Function that converts a DSD stream into a PCM value. The DSD stream is
 * stored as bits in an array of 32-bit words. Inside a word, the MSB is
 * the newest bit, and the LSB is the oldest bit. The words are read from
 * the array with an offset, and are stored wrapped around. Increasing
 * indices from the offset contain words with newer bits.
 *
 * The filter applies N taps, N must be a power of 2 plus 1. The size of
 * the array with the samples, the size of the coefficient array, and the
 * number of words are all related to N as shown below.
 *
 * \param coefficients An array of coefficient values to use for the
 * filter. Should have (N-1)*4 elements for N taps. Should be one of
 * coeff_compressed_513_32 or coeff_compressed_1025_32.
 *
 * \param words_in_window The number of words that contain DSD bits. For N
 * taps, words_in_window should be (N-1)/32.
 *
 * \param words the array of DSD samples, should contain exactly
 * words_in_windows elements.
 *
 * \param offset the element in the words array that contains the oldest
 * DSD samples. Element offset+1 contains newer samples, all the way to
 * offset-1 containing the newest samples. All indices are computed modulo
 * words_in_window.
 *
 * \returns a 32-bit PCM value.
 */
extern int dsd_convert(int coefficients[], int words_in_window, int words[], int offset);

/**
 * Identical to dsd_convert but it uses a coefficient table that is half
 * the size that leads to some extra rounding errors.
 *
 * The filter applies N taps, N must be a power of 2 plus 1. The size of
 * the array with the samples, the size of the coefficient array, and the
 * number of words are all related to N as shown below.
 *
 * \param coefficients An array of coefficient values to use for the
 * filter. Should have (N-1)*4 elements for N taps. Should be one of
 * coeff_compressed_513_16 or coeff_compressed_1025_16.
 *
 * \param words_in_window The number of words that contain DSD bits. For N
 * taps, words_in_window should be (N-1)/32.
 *
 * \param words the array of DSD samples, should contain exactly
 * words_in_windows elements.
 *
 * \param offset the element in the words array that contains the oldest
 * DSD samples. Element offset+1 contains newer samples, all the way to
 * offset-1 containing the newest samples. All indices are computed modulo
 * words_in_window.
 *
 * \returns a 32-bit PCM value.
 */
extern int dsd_convert_16(short coefficients[], int words_in_window, int words[], int offset);
