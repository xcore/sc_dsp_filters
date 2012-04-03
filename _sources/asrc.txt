module_asr
..........

The Asynchronous Sample Rate converter is capable of deleting sample values
in random places in the input stream. This operation introduces harmoic
distortion, but can be used when two asynchronous clocks provide data and
you want to keep them in sync.

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
    filter will be sqaure that size. Supported values are 8 (default)
    and 16. Higher values create less audible artifacts, but increase
    latency in the signal, and increase computational requirements; both
    linear.


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

.. literalinclude:: app_example_asr/src/main.xc
  :start-after: //::reclockexample
  :end-before: //::


A more complex example has two input streams, and it will delete a sample
on either stream when it runs ahead too far.

.. literalinclude:: app_example_asr/src/main.xc
  :start-after: //::twoexample
  :end-before: //::

