module_asr
..........

The Asynchronous Sample Rate converter is capable of deleting sample values
in random places in the input stream. This operation introduces harmoic
distortion, but can be used when two asynchronous clocks provide data and
you want to keep them in sync.

API
---

Types
'''''

.. doxygenstruct:: asrState
           
Functions
'''''''''

.. doxygenfunction:: asrInit

.. doxygenfunction:: asrDelete

Example
'''''''

A simple example on how to use it is shown below. **to be provided**


A more complex example has two input streams, and it will delete a sample
on either stream when it runs ahead too far.

.. literalinclude:: app_example_asr/src/main.xc
  :start-after: //::twoexample
  :end-before: //::

