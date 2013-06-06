Using FIR filters
.................

TO use a FIR filter you need to (1) compute a set of FIR coefficients and
(2) insert these coefficients in the source code and call the FIR function
to perform a FIR.


Computing FIR coefficients
--------------------------

The program to compute the filter coefficients is in build_fir_coefficients
directory. It accepts the following options:

==================== =======================================
Option               Effect
==================== =======================================
-low freq            Lowpass filter, with given corner freq
-high freq           Highpass filter, with given corner freq
-bp freql freqh      Bandpass filter, with given frequencies
-bs freql freqh      Bandstop filter, with given frequencies
-gaussian            Gaussian window
-blackman            Blackman window
-hamming             Hamming window (default)
-hann                Hann window
-n taps              Number of taps - should be odd
-fs freq             Sample frequency, default 48000
-xc sourceFileName   name of source file, default coeffs.xc
-csv csvFileName     name of csv file, default response.csv
==================== =======================================

A single windowing function can be specified, if none is specified a
Hamming window is used. The number of taps must be specified and must be
odd. The corner frequency defaults to 48 KHz.

One or more of -low, -high, -bp, or -bs must be specified. This creates a
single FIR that implements the cascade of filters specified.

The program outputs a source code file that initialises the coefficients
table, and a CSV file that contains the response curves.

The program outputs a percentage error, indicating roughly how much of your
filter got lost because of limitations in the number of taps and the
windowing. If the error is high, you can try and increase the number of
taps. Note that low cut-off frequencies (relative to the sample frequency)
require a high number of taps.

Calling simple FIR
------------------

The function that performs the run time fir is in module_fir. Include the
file fir.h and call::

  filteredSample = fir(sampleValue, coefficientTable, stateTable, N)

sampleValue should be a 8.24 fixed point number, and the function returns
the filtered 8.24 value. CoefficientTable is the name of the array that
was produced by the code above, stateTable should be an array of N integers
which is initialised to all zeroes prior to the first call to fir, and N is
the number of taps (the -n parameter above). The stateTable will contain
N old samples.

Calling optimised FIR
---------------------

The optimised fir also resides in module_fir. There are 5 ways to call this
function: running the code inside the current thread, or running it in 1,
2, 3, or 4 separate threads (on the same core so to share the coefficients
table).

In 1 to 4 extra threads
+++++++++++++++++++++++

Create your coefficient table (N elements), and create four temporary arrays (N/4+12
elements each); N must be a multiple of 48. Now create a process as
follows::

  par {
     ...
     fir_par4_48(coeffs, N, cin, data0, data1, data2, data3);
     ...
  }

``cin`` should be a streaming channel. Each sample to be filtered should be
output onto this channel as a signed integer. Once a sample has been
output, the filtered value should be input on the channel as a ``long
long``; which is the 64 bit result.

In order to use three threads, call the function ``fir_par3_36`` and pass
one array less; make sure that all arrays have at least N/3+12 elements.

In order to use two threads, call the function ``fir_par2_24`` and pass
two temporary arrays only; make sure that they have at least N/2+12 elements.

In order to use one thread, call the function ``fir_par1_12`` and pass
one temporary array only which must have N+12 elements.

Inside the current thread
+++++++++++++++++++++++++

Call the function::

  fir12(coefficients, data, w, N);

With your coefficients, the data, N elements, and an index w indicating the
index of the most recent sample in the data array. data[w] should be the
most recent sample, data[w+1] should be the previous sample, etc. Note that
data should be N+12 samples long, and that data[0..11] should be replicated
in data[N..N+11]. See the code in fir_par1_12 for an example how to drive
it.
