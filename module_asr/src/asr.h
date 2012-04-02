// Copyright (c) 2012, XMOS Ltd, All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#define ASR_ORDER 8
#define ASR_ARRAY (ASR_ORDER+1)

/** Structure that is used to store the state of the converter. One
 * structure should be declared for each channel that the converter is
 * executed on. The internals of this structure are relevant only inside
 * the converter and should not be relied upon by the caller.
 */
struct asr_buffer {
    int wr;                 /**< Current index in historic sample value,
                             * points one above the last value written */
    int insertIndex;        /**< whether we are currently interpolating,
                             * and if so where */
    int buffer[ASR_ARRAY];  /**< historic sample values */

};

/** Function that initialises the asynchronous sample rate converter. This
 * resets the state.
 *
 * \param state buffer structure containing past sample values for
 *              interpolation
 */
void asrInit(struct asr_buffer &state);

/** Function that produces a new sample, possibly interpolating. To be
 * called on every sample, set the parameter ``delete`` to 1 to indicate
 * that this sample is to be deleted.
 *
 * \param sample current sample value
 * 
 * \param delete boolean to indicate that a sample shall be deleted from
 *               the stream. When delete is true, the return value of this
 *               function should be ignored.
 *
 * \param state buffer structure containing past sample values for
 *              interpolation
 *
 * \returns an interpolated sample value, or 0 if delete is true.
 */
int asrDelete(int sample, int delete, struct asr_buffer &state);
