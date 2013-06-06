/** Function that computes a FIR in 4 separate threads/logical cores. This
 * function will only return on an error, otherwise it will compute FIRs
 * forever. You provide data samples over a streaming channel end, and
 * receive the filtered data back over the same streaming channel.
 * 
 * \param coefficients  The FIR coefficients. This must be an array
 *                      of N elements
 *
 * \param N             The number of coefficients, this must be a
 *                      multiple of 48
 *
 * \param cin     channel over which to supply samples. Samples should be
 *                      supplied as a 32 bit int. The filtered data comes
 *                      back over this channel as a 64-bit long long. You
 *                      must input one long long after you have output one
 *                      int.
 *
 * \param data0         This should be an array of N/4+12 elements, for use
 *                      by the FIR processes.
 * \param data1         This should be an array of N/4+12 elements, for use
 *                      by the FIR processes.
 * \param data2         This should be an array of N/4+12 elements, for use
 *                      by the FIR processes.
 * \param data3         This should be an array of N/4+12 elements, for use
 *                      by the FIR processes.
 */

extern void fir_par4_48(int coefficients[], int N, streaming chanend cin,
                        int data0[], int data1[], int data2[], int data3[]);

/** Function that computes a FIR in 3 separate threads/logical cores. This
 * function will only return on an error, otherwise it will compute FIRs
 * forever. You provide data samples over a streaming channel end, and
 * receive the filtered data back over the same streaming channel.
 * 
 * \param coefficients  The FIR coefficients. This must be an array
 *                      of N elements
 *
 * \param N             The number of coefficients, this must be a
 *                      multiple of 36
 *
 * \param cin     channel over which to supply samples. Samples should be
 *                      supplied as a 32 bit int. The filtered data comes
 *                      back over this channel as a 64-bit long long. You
 *                      must input one long long after you have output one
 *                      int.
 *
 * \param data0         This should be an array of N/3+12 elements, for use
 *                      by the FIR processes.
 * \param data1         This should be an array of N/3+12 elements, for use
 *                      by the FIR processes.
 * \param data2         This should be an array of N/3+12 elements, for use
 *                      by the FIR processes.
 */

extern void fir_par3_36(int coefficients[], int N, streaming chanend cin,
                        int data0[], int data1[], int data2[]);

/** Function that computes a FIR in 2 separate threads/logical cores. This
 * function will only return on an error, otherwise it will compute FIRs
 * forever. You provide data samples over a streaming channel end, and
 * receive the filtered data back over the same streaming channel.
 *
 * \param coefficients  The FIR coefficients. This must be an array
 *                      of N elements
 *
 * \param N             The number of coefficients, this must be a
 *                      multiple of 24
 *
 * \param cin     channel over which to supply samples. Samples should be
 *                      supplied as a 32 bit int. The filtered data comes
 *                      back over this channel as a 64-bit long long. You
 *                      must input one long long after you have output one
 *                      int.
 *
 * \param data0         This should be an array of N/2+12 elements, for use
 *                      by the FIR processes.
 * \param data1         This should be an array of N/2+12 elements, for use
 *                      by the FIR processes.
 */


extern void fir_par2_24(int coefficients[], int N, streaming chanend cin,
                        int data0[], int data1[]);


/** Function that computes a FIR in a separate threads/logical cores. This
 * function will only return on an error, otherwise it will compute FIRs
 * forever. You provide data samples over a streaming channel end, and
 * receive the filtered data back over the same streaming channel.
 *
 * \param coefficients  The FIR coefficients. This must be an array
 *                      of N elements
 *
 * \param N             The number of coefficients, this must be a
 *                      multiple of 12
 *
 * \param cin     channel over which to supply samples. Samples should be
 *                      supplied as a 32 bit int. The filtered data comes
 *                      back over this channel as a 64-bit long long. You
 *                      must input one long long after you have output one
 *                      int.
 *
 * \param data0         This should be an array of N+12 elements, for use
 *                      by the FIR processes.
 */


extern void fir_par1_12(int coefficients[], int N, streaming chanend cin,
                        int data0[]);

