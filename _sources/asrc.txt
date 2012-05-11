module_asrc
...........

The Asynchronous Sample Rate converter is capable of deleting or inserting
samples in arbitrary places in the input stream. This operation introduces
harmoic distortion, but can be used when two asynchronous clocks provide
data that must be kept in sync.

API
---


Configuration defines
'''''''''''''''''''''

**ASRC_ORDER**

    This sets the number of samples over which to smooth the signal. The
    filter will be sqaure that size. Higher values create less audible
    artifacts, but increase latency in the signal, and increase
    computational requirements; both linear.

**ASRC_UPSAMPLING**

    This sets the number of steps over which the lost/added sample is
    generated. The higher the value, the lower the noise floor. However,
    higher valus require more memory (the coefficient array is of size
    ASRC_ORDER * ASRC_UPSAMPLING), and it reduces the number of samples
    that can be inserted or deleted.


The default values for ``ASRC_ORDER`` and ``ASRC_UPSAMPLING`` are 8
and 125. At present, the only other combination supported is 8 and 64. In
order to support other combinations, compute the coefficients for a
low-pass FIR filter (using the ``makefir`` program in this repo) with the
following properties:

* Corner frequency: -low 24000

* Sampling rate: -fs ``48000 * ASRC_UPSAMPLING``

* Number of taps: -n ``ASRC_UPSAMPLING * ASRC_ORDER + 1``

* Scale value: -one ``16777216 * ASRC_UPSAMPLING``

Delete the second half of the generated values, (the filter will be
symmetrical) so that you are left with
``(ASRC_UPSAMPLING * ASRC_ORDER)/2 + 1``
coefficients, and so that the last value of the array is ``16777216``.

Types
'''''

.. doxygenstruct:: asrcState
           
Functions
'''''''''

.. doxygenfunction:: asrcInit

.. doxygenfunction:: asrcFilter

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
'''''''''''

The filtering function performs a low pass filter when inserting or
deleting, which requires computation linear in ASRC_ORDER. As an
indication, when ASRC_ORDER = 4, the worst case execution path is a double
call to the filter function (to delete a sample), this takes 170 thread
cycles or 3.4 us at 50 MIPS. This worst case is guaranteed to happen
only once per deleted sample, and typical performance when filtering is 110 thread cycles or
2.2 us at 50 MIPS. Hence, if this function is called just prior to
delivering an audio sample in a 48 KHz stream, then a single thread at 50
MIPS can filter around 6 streams at 48 KHz, or 3 streams at 96 KHz. If used
in a system with a small buffer, 9 streams can be processed.

Distortion
''''''''''

Below we show the frequency analysyis of a 1KHz sinewave that has been
slowed down or sped up using the Asynchronous Sample Rate converter with
upsampling rates of between 64 and 250, and filters of orders 4, 8, and 16.
This experiment used a 48 KHz sample rate at 24 bits. Note that order 16
does not make a significant difference; for many applications order 4 or 8
will be sufficient.

.. figure:: 1kHz-8-125-fast.*
   :width: 100%

   ASRC_ORDER=8 ASRC_UPSAMPLING=125 conversion to slightly faster clock, 2KByte coefficients


.. figure:: 1kHz-8-125-slow.*
   :width: 100%

   ASRC_ORDER=8 ASRC_UPSAMPLING=125 conversion to slightly slower clock, 2KByte coefficients

.. figure:: 1kHz-8-64-slow.*
   :width: 100%

   ASRC_ORDER=8 ASRC_UPSAMPLING=64 conversion to slightly slower clock, 1KByte coefficients


.. figure:: 1kHz-16-64-slow.*
   :width: 100%

   ASRC_ORDER=16 ASRC_UPSAMPLING=64 conversion to slightly slower clock, 2KByte coefficients


.. figure:: 1kHz-4-125-slow.*
   :width: 100%

   ASRC_ORDER=4 ASRC_UPSAMPLING=125 conversion to slightly slower clock, 1KByte coefficients


.. figure:: 1kHz-4-250-slow.*
   :width: 100%

   ASRC_ORDER=4 ASRC_UPSAMPLING=250 conversion to slightly slower clock, 2KByte coefficients

