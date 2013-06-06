DSP Filtering
=============

DSP filters perform functions such as low-pass or peaking filters. Filters
work in the time domain, and do
not transform data from the time to frequency domains; look for
sc_dsp_transforms for that.

There are shelves of textbooks that cover filtering; a two-page summary is
necessarily incomplete. Typical characterisations of filters include:

* Sample rate. Input and output sample rates may be
  identical, or the filter may perform some form of sample-rate conversion
  (eg, 44.1 to 48 KHz audio)

* Number of channels. The number of channels on which identical filters are
  performed. For example, two audio channels that have identical treble and
  bass settings.

* Precision. The number of bits before and after the binary point that
  contain valid data. Typical precisions are 16 bits or 24 bits for audio
  signals, or XXX for motor control.

  Inside the filter, data is accumulated with a
  certain precision. This may be higher precision than the input operation
  in order to avoid accumulative rounding errors.

* Overflow. What to do on overflow: saturate, wrap around, or trap.

* Rounding. After a filter round there will be some bits that are
  discarded, and some for of rounding needs to take place. Typical ones
  include dithering (adding triangular noise in the range [-0.5 .. 0.5]),
  or ordinary rounding.

* Type of filter. The two main classes are Finite Impulse Response (FIR)
  and Infinite Impulse Response (IIR). For FIR filters the number of "taps"
  needs to be specified (that is, the number of coefficients to filter with).

* The filter coefficients. This is often where a company adds value. There
  are many methods for computing coefficients for, for example, low-shelf,
  or bandpass filters, but all have imperfect responses. A domain expert
  can create filter-coefficients that have a good response for a particular
  domain.

As a rule of thumb, computational requirements are linear in the sample
rate and linear in the number of channels. Double either, and the
computational requirements doubles. Double both and the computations go up
four-fold. 

Most filters are based around 32-bit input data, with a 64-bit accumulator.
The coefficients should be worked out so that there is sufficient
"headroom" in the accumulator and in the data. For example, if all data
samples are between -1 and +1 represented as a 24-bit signed number, then
there are 7-bits (32 - 24 data bits - 1 sign bit) headroom. All numbers are
represented as fixed-point numbers, and the precision is defined by the
filter. 

Typically, overflow leads to saturation, but this adds computational
complexity, and may be removed if not desired. Numbers are typically
rounded to the nearest value, with 0.5 being rounded up.

There are at present three modules, an FIR filter, a Biquad filter and an
Asynchronous Sample Rate Converter. The Biquad the latter implements an IIR
filter. Scripts are provided to compute coefficients, but it is worth
noting that these are textbook computations, and that better coefficients
can be designed by domain experts.


module_cascading_biquad
-----------------------

This module provides a function that filters a data stream through a series
of N Biquads. The input data is in 8.24 format, a sign bit, seven bits
before the binary point, and 24 bits behind the binary point. Assuming a
single 50 MIPS thread:

+------------------------+----------------------------------+-------------+
| Functionality provided | Resources required               | Status      |
+----------+-------------+-------------+---------+----------+             |
| Channels | Filters     |Thread cycles|Max rate | Memory   |             |
+----------+-------------+-------------+---------+----------+-------------+
| 1        | 1           | 53          | 943 KHz | ? KB     | Implemented |
+----------+-------------+-------------+---------+----------+-------------+
| 2        | 1           | 106         | 471 KHz | ? KB     | Implemented |
+----------+-------------+-------------+---------+----------+-------------+
| 1        | 2 in series | 77          | 649 KHz | ? KB     | Implemented |
+----------+-------------+-------------+---------+----------+-------------+
| M        | N in series | M (29+24 N) | 50/...  | ? KB     | Implemented |
+----------+-------------+-------------+---------+----------+-------------+

Biquads that are executed in parallel can be implemented at a similar cost,
but lead to interesting phase shifts.

module_fir
----------

The FIR module implements a function that performs a single FIR. If
multiple FIRs are to be applied, the coefficients can be summed at compile
time. Its performance depends on the number of taps and the number of
logical cores that are deployed. There are two versions of the FIR: one is
simple, not efficient, but works on any lenght filter; the other is highly
optimised but it requires the filter length to be a mulitple of 12. The
numbers are below are for a single channel - multiple channels scale
linearly. All times are measured on an empty 400 MHz processor, ie, this
assumes there are 1, 2, 3, or 4 threads that have 100 MIPS each.

General and simple version:

+------------------------+----------------------------------+------------------+
| Functionality provided | Resources required               | Status           |
+----------+-------------+-------------+---------+----------+                  |
| Threads  | Taps        |Thread cycles|Max rate | Memory   |                  |
+----------+-------------+-------------+---------+----------+------------------+
| 1        | 1           | 43          | 1.1 MHz | ? KB     | Implemented, TBC |
+----------+-------------+-------------+---------+----------+------------------+
| 1        | 2           | 43          | 943 KHz | ? KB     | Implemented, TBC |
+----------+-------------+-------------+---------+----------+------------------+
| 1        | N           | (33+10 N)   | 50/...  | ? KB     | Implemented, TBC |
+----------+-------------+-------------+---------+----------+------------------+

Efficient version, requires number of taps to be a multiple of 12:

+------------------------+----------------------------------+------------------+
| Functionality provided | Resources required               | Status           |
+----------+-------------+-------------+---------+----------+                  |
| Threads  | Taps        | Time in ns  |Max rate | Memory   |                  |
+----------+-------------+-------------+---------+----------+------------------+
| 1        | 48          | 2760        | 362 KHz | ? KB     | Implemented, TBC |
+----------+-------------+-------------+---------+----------+------------------+
| 4        | 48          | 1160        | 862 KHz | ? KB     | Implemented, TBC |
+----------+-------------+-------------+---------+----------+------------------+
| 1        | 288         | 13950       | 71 KHz  | ? KB     | Implemented, TBC |
+----------+-------------+-------------+---------+----------+------------------+
| 4        | 288         | 3940        | 253 KHz | ? KB     | Implemented, TBC |
+----------+-------------+-------------+---------+----------+------------------+
| 1        | large N     | 46.625 N    | 21/N MHz| ? KB     | Implemented, TBC |
+----------+-------------+-------------+---------+----------+------------------+
| 4        | large N     | 11.583 N    | 86/N MHz| ? KB     | Implemented, TBC |
+----------+-------------+-------------+---------+----------+------------------+

(Note: it may be possible to cleverly jump into the loop and get an
efficient version that enables any number of coefficients, this is To Do)

module_asrc
-----------

The ASRC module implements a function that performs a Asynchronous Sample
Rate Conversion. The module delays the signal by five samples, or around
100 us at 48 KHz. The noise floor is below -90db, with some noise near the
main frequency at -60db. The maximum sample rate given assumes a single 50
MIPS thread solely dedicated to this task. Performance figures given here
are absolute worst case - see the performance discussion in the API section
(:ref:`sc_dsp_filters_asrc_performance`) for a more detailed explanation.

+----------------------------+----------------------------------+-------------+
| Functionality provided     | Resources required               | Status      |
+-------+-------+------------+-------------+---------+----------+             |
| Chans | Order | Upsampling |Thread cycles|Max rate | Memory   |             |
+-------+-------+------------+-------------+---------+----------+-------------+
| 1     | 8     | 128        | 210         | 238 kHz | 2630 B   | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| 2     | 8     | 128        | 420         | 119 kHz | 2710 B   | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| 4     | 8     | 128        | 840         | 56 kHz  | 2870 B   | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| N     | 8     | 128        | 210 N       | 238/N   | 2550+80N | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| 1     | 8     | 64         | 210         | 238 kHz | 1630 B   | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| 2     | 8     | 64         | 420         | 119 kHz | 1710 B   | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| 4     | 8     | 64         | 840         | 56 kHz  | 1870 B   | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| N     | 8     | 64         | 210 N       | 238/N   | 1550+80N | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| 1     | 4     | 256        | 170         | 294 kHz | 2630 B   | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| 2     | 4     | 256        | 340         | 147 kHz | 2710 B   | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| 4     | 4     | 256        | 680         | 73 kHz  | 2870 B   | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+
| N     | 4     | 256        | 170 N       | 294/N   | 2550+80N | Implemented |
+-------+-------+------------+-------------+---------+----------+-------------+

This implementation optimises per-sample latency. If throughput is
important then a multi-channel version can be implemented that
simultaneously operates on all channels, reducing overhead.
