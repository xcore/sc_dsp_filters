// Copyright (c) 2012, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#define ASRC_ORDER 8
#define ASRC_ARRAY 10

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
 * resets the state.
 *
 * \param state buffer structure containing past sample values for
 *              interpolation
 */
void asrcInit(struct asrcState &state);

/** Function that produces a new sample, possibly interpolating. To be
 * called on every sample. Set the parameter ``diff`` to -1 or +1 to
 * indicate that a sample is to be deleted or inserted. Anytime that this
 * function is called with a request to delete or insert a sample, at least
 * eight calls should be made without deletion for the signal to stabilise.
 *
 * When ``diff`` is -1, the return value of the function should be ignored,
 * this accounts for the deleted sample. When ``diff`` is +1, the input
 * sample to the function will be ignored, this accounts for the inserted
 * sample.
 *
 * \param sample current sample value. Ignored if ``diff`` is +1.
 * 
 * \param diff value to indicate that a sample shall be deleted or inserted
 *               from the stream. When -1, a value shall be deleted and the
 *               return value of this function should be ignored. When +1 a
 *               value shall be inserted into the stream, and the sample
 *               passed into the function will be ignored.
 *
 * \param state buffer structure containing past sample values for
 *              interpolation
 *
 * \returns an interpolated sample value. To be ifnored if ``diff`` is -1.
 */
int asrcFilter(int sample, int diff, struct asrcState &state);
