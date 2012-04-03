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

Types
'''''

.. doxygenstruct:: asrcState
           
Functions
'''''''''

.. doxygenfunction:: asrcInit

.. doxygenfunction:: asrcFilter

Example
'''''''

A simple example on how to use it is shown below. **to be provided**


A more complex example has two input streams, and it will delete a sample
on either stream when it runs ahead too far.

.. literalinclude:: app_example_asr/src/main.xc
  :start-after: //::twoexample
  :end-before: //::


.. literalinclude:: app_example_asr/src/main.xc
  :start-after: //::reclockexample
  :end-before: //::

