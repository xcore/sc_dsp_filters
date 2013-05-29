#define FIR_MODULO 12

/** This function computes a FIR over two arrays of data. It is computed
 * over N points, on the coefficients array elements 0..N-1 and the data
 * array elements offset...N 0...offset-1.
 *
 * This function is optimised and as a consequence requires a slightly odd
 * setup of the data array. The data array should contain the samples in
 * positions 0..11 to be repeated in places N..N+11 (it enables aggressive
 * loop unrolling). 
 *
 * \param coefficients array with coefficients. N elements long
 *
 * \param data         array with samples. N+12 elements long
 *
 * \param offset       The first data sample, must be between 0 and N-1 inclusive
 *
 * \param N            The number of elements, must be a multiple of 12.
 *
 * \returns            The 64 bit FIR. Headroom should be kept in coefficients or data to prevent overflow.
 */
long long fir12(int coefficients[], int data[], int offset, int N);
