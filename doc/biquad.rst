Using Biquad filters
....................

TO use a Biquad filter you need to (1) compute a set of Biquad coefficients and
(2) insert these coefficients in the source code and call the Biquad function
to perform a Biquad.


Computing Biquad coefficients
-----------------------------

The program to compute the filter coefficients is in build_biquad_coefficients
directory. It accepts the following options:

==================== =======================================
Option               Effect
==================== =======================================
-low freq            Low shelf filter, with given corner freq
-high freq           High shelf filter, with given corner freq
-peaking freq bw     PeakingEQ filter, with given corner freq and bw in octaves
-min minDb           minimal dB value, default -20
-max maxDb           maximal dB value, default +20
-step dbStep         Dbs between each step, default 1
-fs freq             Sample frequency, default 48000
-h includeFileName   name of include file, default coeffs.h
-xc sourceFileName   name of source file, default coeffs.xc
-csv csvFileName     name of csv file, default response.csv
==================== =======================================


At least one of -low, -high, -bp, or -bs must be specified, it builds a set
of biquad coefficients for each filter. For each biquad it generates a
table for each dB gain level, from min to max in the given number of steps.
Example calls are::

  -min -20 -max 20 -step 4 -low 250 -high 4000
  -low 400 -peaking 800 1 -peaking 1600 1 -high 3200

The program outputs an include file, a source code file that initialises the coefficients
table, and a CSV file that contains the response curves.

Calling Biquad
--------------

The function that performs the run time fir is in module_cascading_biquad. Inlcude the
file fir.h and call::

  filteredSample = biquadCascade(state, sampleValue);

sampleValue should be a 8.24 fixed point number, and the function returns
the filtered 8.24 value. The variable state holds the state of all biquads,
it has to be initialised as follows:

  initBiquads(state, zeroDb);

Where zeroDb is the index into the db table that is 0 dB, 20 in the default
setting (from -20 db in steps of 1 db).
