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

One of -low, -high, -bp, or -bs must be specified. If you want multiple
filters you need to run the program several times and sum together the
coefficients. (TODO: allow one or more of those options, and sum them in
the program).

The number of taps should be odd.

The program outputs a source code file that initialises the coefficients
table, and a CSV file that contains the response curves.

The program outputs a percentage error, indicating roughly how much of your
filter got lost because of limitations in the number of taps and the
windowing. If the error is high, you can try and increase the number of
taps. Note that low cut-off frequencies (relative to the sample frequency)
require a high number of taps.

Calling FIR
-----------

The function that performs the run time fir is in module_fir. Inlcude the
file fir.h and call::

  fir(sampleValue, coefficientTable, stateTable, N)

sampleValue should be a 8.24 fixed point number, coefficientTable is wha
was produced by the code above, stateTable should be an array of N integers
which is initialised to all zeroes prior to the first call to fir, and N is
the number of taps (the -n parameter above).
