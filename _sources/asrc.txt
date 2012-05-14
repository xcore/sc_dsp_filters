module_asrc
...........

The Asynchronous Sample Rate converter is capable of deleting or inserting
samples in arbitrary places in the input stream. This operation can be used
when an incoming signal has to be synchronised with a local clock.
By nature this operation introduces harmonic distortion that can be
minimised by setting the filter to a high upsampling rate and high order.

API
---

There are two interfaces to the ASRC module. The first interface is a
simlpe interface that manages the deletion and insertion of samples at
arbitrary places. After initialisation, a single function ``asrcFilter()``
is called that takes care of buffer management and interpolation.

The second interface is slightly more complex but enables continuous
interpolation of a signal; but buffer management has to be taken care of by
the caller: ``asrcContinuousBuffer()`` adds a sample to the buffer
and ``asrcContinuousInterpolate()`` interpolates a sample given a
fractional position. The fractional position is a number between 0 and 1
inclusive. If, for example, the stream is too fast, the caller will
increase the fractional position gradually, and when it reaches 1 an extra
sample should be added to the buffer, and the fractional position be reset
to 0. Similarly, rather than decreasing the fractional position to below
zero, it should wrap back to 1 and an extra interpolation should take place.


Configuration defines
'''''''''''''''''''''

**ASRC_ORDER**

    This sets the number of samples over which to smooth the signal. A
    higher value creates less audible artifacts, but increases latency and
    computational requirements linearly. Must be a power of 2 to simplify
    buffer management.

**ASRC_UPSAMPLING**

    This sets the number of steps over which the lost/added sample is
    generated. The filter can only insert or delete a sample once during
    the upsampling period. The higher the value, the lower the noise floor.
    Higher values require more memory (the coefficient array is of size
    ASRC_ORDER * ASRC_UPSAMPLING). ASRC_UPSAMPLING should be a power of 2
    in order to simplify the fractional sample location used by
    ``asrcContinuousInterpolate()``


The default values for ``ASRC_ORDER`` and ``ASRC_UPSAMPLING`` are 8
and 128. For each combination a table of coefficients is required. Tables
are defined as part of the module (in ``coeffs.xc``) for the following combinations:

* 4 and 256

* 4 and 128

* 8 and 128

* 8 and 64

* 16 and 64

To support other combinations, compute the coefficients for a
low-pass FIR filter (using the ``makefir`` program in this repo) with the
following parameters:

* Corner frequency: -low ``1``

* Sampling rate: -fs ``2 * ASRC_UPSAMPLING``

* Number of taps: -n ``ASRC_UPSAMPLING * ASRC_ORDER + 1``

* Scale value: -one ``16777216 * ASRC_UPSAMPLING``

Delete the second half of the generated values, (the filter will be
symmetrical) so that you are left with ``(ASRC_UPSAMPLING * ASRC_ORDER)/2 +
1`` coefficients, and so that the last value of the array is ``16777216``.
Add this array to an appropriate ``#elif`` in ``coeffs.xc``



Types
'''''

.. doxygenstruct:: asrcState
           
Functions
'''''''''

.. doxygenfunction:: asrcInit

.. doxygenfunction:: asrcFilter

.. doxygenfunction:: asrcContinuousBuffer

.. doxygenfunction:: asrcContinuousInterpolate

Example
'''''''

A simple example reclocks an input stream to a given wordclock. The
assumption are that both input stream and wordclock are stable, and almost
the same frequency. A sample is added or deleted when the stream runs out
of sync too far with the word clock

.. literalinclude:: app_example_asrc/src/main.xc
  :start-after: //::reclockexample
  :end-before: //::


A more complex example has two input streams, and it will delete a sample
on either stream when it runs ahead too far.

.. literalinclude:: app_example_asrc/src/main.xc
  :start-after: //::twoexample
  :end-before: //::

.. _sc_dsp_filters_asrc_performance:

Performance
-----------

The filtering function performs a low pass filter when inserting or
deleting, which requires computation linear in ASRC_ORDER. As an
indication, when ASRC_ORDER = 4, the worst case execution path is a double
call to the filter function (to delete a sample), this takes 170 thread
cycles or 3.4 us at 50 MIPS. This worst case is guaranteed to happen
only once per deleted sample, and typical performance when filtering is 110 thread cycles or
2.2 us at 50 MIPS. Hence, if this function is called just prior to
delivering an audio sample in a 48 kHz stream, then a single thread at 50
MIPS can filter around 6 streams at 48 kHz, or 3 streams at 96 kHz. If used
in a system with a small buffer, 9 streams can be processed at 48 kHz.

Distortion
----------

Below we show the frequency analysyis of a 1kHz sinewave that has been
sped up using the Asynchronous Sample Rate converter with
upsampling rates of between 64 and 250, and filters of orders 4, 8, and 16.
This experiment used a 48 kHz sample rate at 24 bits. Note that order 4
will be sufficient for many applications.

.. figure:: 100ppm-1K.*
   :width: 100%

   conversion to slightly faster clock, 1KByte coefficients


.. figure:: 100ppm-2K.*
   :width: 100%

   conversion to slightly faster clock, 2KByte coefficients

