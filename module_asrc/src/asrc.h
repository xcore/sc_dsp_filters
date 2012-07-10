// Copyright (c) 2012, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

/*! \file */


#ifndef ASRC_ORDER
#define ASRC_ORDER 8
#endif

#ifndef ASRC_UPSAMPLING
#define ASRC_UPSAMPLING 128
#endif

#if (ASRC_ORDER == 4)
#define ASRC_ARRAY 8
#elif (ASRC_ORDER == 8)
#define ASRC_ARRAY 16
#elif (ASRC_ORDER == 16)
#define ASRC_ARRAY 32
#else
#error "Undefined ASRC_ORDER, set to 4, 8 or 16"
#endif

/** Structure that is used to store the state of the converter. One
 * structure should be declared for each channel that the converter is
 * executed on. The internals of this structure are relevant only inside
 * the converter and should not be relied upon by the caller.
 */
struct asrcState {
    int wr;                 /**< Current index in historic sample value,
                             * points one above the last value written */
    int firStart;           /**< The first point of the FIR to use */
    int state;              /**< Inserting, Deleting, or Neither */ 
    int buffer[ASRC_ARRAY]; /**< historic sample values */

};

/** Function that initialises the asynchronous sample rate converter. This
 * resets the state and should be called once for each ``struct acrcState``
 * declared.
 *
 * \param state buffer structure containing past sample values for
 *              interpolation
 */
void asrcInit(struct asrcState &state);

/** Function that produces a new sample, possibly interpolating. To be
 * called on every sample. Set the parameter ``diff`` to -1 or +1 to
 * indicate that a sample is to be deleted or inserted. Anytime that this
 * function is called with a request to delete or insert a sample, at least
 * ASRC_UPSAMPLING+1 calls should be made with ``diff`` set to 0 for the
 * interpolation to complete.
 *
 * When ``diff`` is -1, the return value of the function should be ignored,
 * this accounts for the deleted sample. When ``diff`` is +1, the input
 * sample to the function will be ignored, this accounts for the inserted
 * sample.
 *
 * \param sample current sample value. Ignored if ``diff`` is +1.
 * 
 * \param diff   value to indicate that a sample shall be deleted or inserted
 *               from the stream. When -1, a value shall be deleted and the
 *               return value of this function should be ignored. When +1 a
 *               value shall be inserted into the stream, and the sample
 *               passed into the function will be ignored.
 *
 * \param state  buffer structure containing past sample values for
 *               interpolation
 *
 * \returns      an interpolated sample value. To be ignored if ``diff`` is -1.
 */
int asrcFilter(int sample, int diff, struct asrcState &state);

/** UNTESTED Continuous interface to ASRC: add a sample to the buffer. This must be
 * called once for every input sample. Occasionally an extra or missing
 * call to asrcContinuousInterpolate() compensates for the asynchronous
 * nature
 *
 * \param sample current sample value.
 *
 * \param state  buffer structure containing past sample values for
 *               interpolation
 */
void asrcContinuousBuffer(int sample, struct asrcState &state);

/** UNTESTED Continous interface to ASRC: called once for each sample to be produced
 * on the output stream. The value is computed given the previous
 * ASRC_ORDER samples in the buffer that have been added with
 * asrcContinuousBuffer(). An interpolated value is returned, notionally
 * between ASRC_ORDER+1 and ASRC_ORDER samples in the past. A fractional
 * value of 0.0 indicates sample ASRC_ORDER+1 in the past, 1.0 indicates
 * ASRC_ORDER samples in the past, 0.5 a value exactly inbetween, etc.
 *
 * \param frac fractional sample - a number between 0 and 1 inclusive,
 *             where 1 is represented by ASRC_UPSAMPLING.
 *
 * \param state  buffer structure containing past sample values for
 *               interpolation
 * 
 * \returns the interpolated sample value.
 */
int asrcContinuousInterpolate(int frac, struct asrcState &state);
