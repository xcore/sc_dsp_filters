module_asr
..........

The Asynchronous Sample Rate converter is capable of deleting or inserting
samples in arbitrary places in the input stream. This operation introduces
harmoic distortion, but can be used when two asynchronous clocks provide
data that must be kept in sync.

The filtering function performs a low pass filter when inserting or
deleting. The filtering function takes approximately 2.5 us per sample.
Channels must be filtered independently, so a stereo stream will require 5
us per sample. (all assuming a 50 MIPS thread). Hence a single thread at 50
MIPS can filter around 8 streams at 48 KHz, or 2 streams at 192 KHz.

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

