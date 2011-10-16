module_cascading_biquad
.......................

The biquad library provides a cascade of biquad filters, each performing a
specific filter operation. A typical use is to get one filter to perform a
low shelf (bass boost), one filter to perform a high shelf gain (treble
boost) and a number of filters to boost specific bands. Put in series, this
implements a "graphical equaliser".

In general filters can be static (for example, a low shelf 400 Hz filter at
+20dB to create bass boost), or dynamic (for example a low shelf 400 Hz
filter at anything between -20 and +20 dB). The current code base assumes
that filters are dynamic, and that there is a precomputed table of
coefficients for all filter for all possible dB values. This enables the
filter to gradually change coefficients when a new dB value is desired. It
is simple to remove the code that reacts to responses in the dB value and
that just uses a single static dB value for each filter.

The module is optimised for performance, and assumes that there is a series
of channels that will all be filtered using the same table of coefficients
and dB values, but with separate dB settings for separate channels.

The rest of this section explain the two parts that this module comprises.
We first document the way to use the module to filter data, *assuming that
there is a set of coefficients*. In order to compute the coefficients, you
can call a provided java program, or you can provide your own coefficients.
Note that the number of banks, the number of dB levels, and the
representations of the numbers are all compile-time constants.

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
    the number 1 is represented as ``1 << FRACTIONALBITS``, -1 is represented
    as ``-1 << FRACTIONALBITS``.

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
0xF7000000 represents -1. Increments of 1 represent increments in 2^-27.
The range of numbers that can be represented is [-16..16).

The coefficient array needs to be defined, for example as follows::

  struct coeff biquads[DBS][BANKS] = {
    {
      {133860500, -261873323, 128137849, 261857137, -127796807},
      {111128665, -137894758,  50929490, 176727474,  -66673143}
    },
    {
      {134217728, -262224926, 128147672, 262224926, -128147672},
      {134217728, -171749357,  64101347, 171749357,  -64101347}
    },
    {
      {134575909, -262555944, 128137853, 262572173, -128479804},
      {162103977, -213445919,  80525738, 166544979,  -61511046}
    }
  };

The first number, 133860500, represents 0.997338443994522, and is the value
of b1/a0 for filter bank 0 db setting 0. Each row represents one of three
possible dB settings. In this example, we have chosen the dB settings -2
dB, 0 dB, and +2 dB. 

To filter two channels we declare two state variables that are both
initialised to use the middle dB index (1) which represents 0 dB::

  biquadState leftState, rightState;

  initBiquads(leftState, 1);
  initBiquads(rightState, 1);

After this samples can be filtered by calling biquadCascade()::

  filteredLeftSample = biquadCascade(leftState, leftSample);
  filteredRightSample = biquadCascade(rightState, rightSample);

To change the left filter bank to use a dB index of 2 for bank 0, set the
desiredDb value as follows::

  leftState.desiredDb[0] = 2;

This will take effect over a period of time.


Computing Biquad coefficients
-----------------------------

Computing biquad coefficients is an science, and coefficients are the special
sauce that many designers add. This module provides a java program that uses a
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
coefficients array ``biquads``. For each filter (-low, -high, -peaking) the
program generates a set of coefficients for each dB gain level, from min to
max in the given number of steps. It can, for example, be invoked as follows::

  -min -20 -max 20 -step 4 -low 250 -high 4000

This generates a table with 11 Db values (-20, -16, -12, -8, -4, 0, 4, 8,
12, 16, 20) and two filters. Filter 0 is a low frequency filter with a
corner frequency of 250 Hz, the latter is a high frequency filter with a
corner frequency of 4000 Hz, assuming a 48 KHz sample frequency. All
coefficients will be represented in the default 8.24 representation.

The program also generates a CSV file that contains the response curves.
The curves are calculated using maths from
http://groups.google.com/group/comp.dsp/browse_frm/thread/8c0fa8d396aeb444/a1bc5b63ac56b686
