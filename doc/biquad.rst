Using Biquad filters
....................

The biquad library provides a cascade of biquad filters, each performing a
specific filter operation. A typical use is to get one filter to perform a
low shelf (bass boost), one filter to perform a high shelf gain (treble
boost) and a number of filters to boost specific bands. Put in series, this
implements a graphics equaliser.

To use a Biquad filter you need to (1) compute a set of Biquad coefficients and
(2) insert these coefficients in the source code and call the Biquad function
to perform a Biquad.



API
---


When biqaudCascade is called the sample is subjected to each biquad in
turn. Initially each biquad filter is set to a 0 dB gain (ie, no change). Between
calls to biquadCascade, the code can change the desiredDb array in the
state variable. This array holds the gain for each biquad, expressed as an
array index: 0 is the minimal gain, and (max-min)/steps is the maximal
gain. Ie, if you have a low-shelf, three peakingEq and a high-shelf biquad,
then the desiredDb array has five elements referring to the filters that
were specified on the command line. The biquadCascade function will slowly
adjust the gain level of each filter to match the desiredDb, enabling a
click-free transition.

API
---

Configuration Defines
'''''''''''''''''''''

The file ``coefficients.h`` must be provided in the application source
code. This file must set the following ``#define`` s:

**BANKS**

    This define sets the number of banks on which the cascaded biquad will
    operate. It is compiled into the binary and is not a parameter. It also
    governs the size of the biquadState and coefficients defined below.

**DBS**

    This define sets the number of dB levels that are provided by the
    coefficient tables. The dB values supported are entirely up to the
    user. Whenever a dB value is to be provided (eg, to initBiquads()) then
    a value in the range [0..DBS-1] is to be provided which is used as a
    lookup in the coefficients table.

**FRACTIONALBITS**

    This define sets the number of bits in the fractional part of
    fixed point numbers used to represent samples and coefficients. 


Types
'''''

.. doxygenstruct:: biquadState

.. doxygenstruct:: coeff

Global constants
''''''''''''''''

.. doxygenvariable:: biquads
           
Functions
'''''''''

.. doxygenfunction:: initBiquads

.. doxygenfunction:: biquadCascade

Example
'''''''

The coefficients and include file can be generated for you (see the next
section), but an example ``coefficients.h`` file is::

  #define BANKS 2
  #define DBS 3
  #define FRACTIONALBITS 27

This file states that we want to cascade two biquad filters, each filter
has three possible dB settings, and all numbers are represented in 5.27
format; that is, there are 27 bits behind the fixed point, and a sign bit
with four bits before the fixed point. Hence, 0x08000000 represents +1 and
0xF7FFFFFF represents -1. Increments of 1 represent increments in 2^-27.
The range of numbers that can be represented is [-16..16).

The coefficient array needs to be defined, for example as follows::

  struct coeff biquads[DBS][BANKS] = {
    {
      {133860500, -261873323, 128137849, 261857137, -127796807},
      {111128665, -137894758,  50929490, 176727474,  -66673143},
    },
    {
      {134217728, -262224926, 128147672, 262224926, -128147672},
      {134217728, -171749357,  64101347, 171749357,  -64101347},
    },
    {
      {134575909, -262555944, 128137853, 262572173, -128479804},
      {162103977, -213445919,  80525738, 166544979,  -61511046},
    },

The first number, 133860500, represents 0.997338443994522, and is the value
of b1 for filter bank 0 db setting 0.

To filter two channels we declare two state variables that are both
initialised to use the middle dB value::

  biquadState leftState, rightState;

  initBiquads(leftState, 1);
  initBiquads(rightState, 1);

After this samples can be filtered by calling biquadCascade():

  filteredLeftSample = biquadCascade(leftState, leftSample);
  filteredRightSample = biquadCascade(rightState, rightSample);

To change the left filter bank to use a dB index of 2 for bank 0, set the
desiredDb value as follows:

  leftState.desiredDb[0] = 2;

This will take effect over a period of time.


Computing Biquad coefficients
-----------------------------

Computing biquad coefficients is an art, and coefficients are the *special
sauce* that many designers add. This module has a java program that uses a
public domain algorithm to compute biquad coefficients. This program is in
the build_biquad_coefficients directory. It accepts the following options:

==================== ===================================================================
Option               Effect
==================== ===================================================================
-low freq            Low shelf filter, with given corner freq
-high freq           High shelf filter, with given corner freq
-peaking freq bw     PeakingEQ filter, with given corner freq and bandwidth in octaves
-bits fractionalBits number of fractional bits, default 24
-min minDb           minimal dB value, default -20
-max maxDb           maximal dB value, default +20
-step dbStep         dBs between each step, default 1
-fs freq             Sample frequency, default 48000
-h includeFileName   name of include file, default coeffs.h
-xc sourceFileName   name of source file, default coeffs.xc
-csv csvFileName     name of csv file, default response.csv
==================== ===================================================================

At least one of -low, -high, -bp, or -bs must be specified. The program
builds both the ``coeffs.h`` file that defines the number of banks, db
levels, and precision, and a ``coeffs.xc`` file that contains the
coefficients. For each filter the program generates a
table for each dB gain level, from min to max in the given number of steps.
Example calls are::

  -min -20 -max 20 -step 4 -low 250 -high 4000
  -low 400 -peaking 800 1 -peaking 1600 1 -high 3200

The program outputs an include file, a source code file that initialises
the coefficients table, and a CSV file that contains the response curves.
The curves are calculated using maths from
http://groups.google.com/group/comp.dsp/browse_frm/thread/8c0fa8d396aeb444/a1bc5b63ac56b686
