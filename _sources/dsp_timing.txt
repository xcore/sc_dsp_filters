XMOS XS1-L1 DSP Performance Application Note
============================================

This application note describes how the XMOS Timing analyzer tool can
be used to measure DSP performance on the XMOS XS-L1 device. In
particular it examines the cascaded biquad filter which is implemented
in the module_cascading_biquad component. This component includes the
functionality to generate an arbitrary number of cascaded biquad
filters along with filter coefficient values.

The initial figures are based on a 400MHz L1 device running only a
single thread, but this application note will explain how XTA can be
used to calculate performance for various configurations of device
speed and thread count.

DSP functionality and performance
---------------------------------

A typical application that would use cascacded biquad filters would be
an audio processing application - such as a multi-band equalizer or a
digital crossover. It could even be a complex equalizer to compensate
for speaker or enclosure performance limitations.

The XS1-L architecture supports a single cycle 32*32 MACC instruction
producing a true 64 bit result which is ideal for fixed point DSP
operation. A single biquad filter requires 5 MACC operations. Around
this are operations to load the coefficients to be applied and to
check for overflow. 

While we could count the assembly instructions required in the
biquadAsm function, instead the XMOS Timing Analyzer (XTA) can be
used to measure the time this function takes. This example is based on
building the app_example_biquad binary. 

XTA can be used either through the XDE GUI or from the command
line. Some familiarity is assumed with the tool which is described in
the XMOS Tools User guide:
http://www.xmos.com/published/tools-user-guide-112
(Chapter 4, Verifying Program Timing)


Measuring performance with an example application
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

This section examines how XTA allows quick and simple worst case
performance measurements to make best use of the available MIPS.

Starting with the app_example_biqaud above, configure a single biquad
filter - edit the "coefficients" section of the Makefile and change
the FILTER section to::

  coefficients:
       make -f ../build_biquad_coefficients/Makefile.mk \
		FILTER='-min -20 -max 20 -step 1 -bits 27 -low 250 ' \
        INCLUDEFILE=src/coeffs.h \
		XCFILE=src/coeffs.xc \
		CSVFILE=response.csv

The main application file in app_example_biquad/src/main.xc will need
to be edited for the case of a single filter to comment out line 128::

          //            bs.desiredDb[1] = 0;

as with only one filter this is out of bounds.     

The above changes will build a single low pass filter and allows us to
get a baseline for performance measurements.

The biquad filter functionality is implemented in the biquadAsm function.
To report useful timing information, XTA requires constraints to be
applied for it to measure against. From the original assumption that a
common application would be audio, we can work out some
constraints. Based on 48kHz sample frequency with 2 channels of audio
sending 1 word per sample, there are 10.4us between samples. 

If XTA is used to analyze this function, it should report the
output below. There is a script (dsp_performance.xta) that will peform
the necessary commands as this is something that will be repeated lots
as we change the DSP parameters::

  function: biquadAsm 
  stdcore[0] (node: 0, core: 0)
  Pass, Num Paths: 14
  Worst Case Timing:    1.1 us,    0.95 MHz,     105 thread cycles
  Required:     10.4 us,    0.10 MHz,    1040 thread cycles
  Slack:        9.4 us,    0.11 MHz,     935 thread cycles
  Min Core Frequency:       40 MHz

We can immediately see that with each call taking 105 cycles and 1040
thread cycles available we should be able to achieve 9 cascaded biquad
filters and still meet timing for the worst case (although only 1
thread is active, the device performance is identical with 1-4 threads
running).

If the Makefile is now edited to increase the number of filters, we
can retime the binary::

   coefficients:
       make -f ../build_biquad_coefficients/Makefile.mk \
		FILTER='-min -20 -max 20 -step 1 -bits 27 -low 100 -high 2000
		-peaking 200 1 -peaking 250 1 -peaking 325 1 -peaking 440 1 -peaking
		600 1 -peaking 1000 1 -peaking 1500 1' \
		INCLUDEFILE=src/coeffs.h \
		XCFILE=src/coeffs.xc \
		CSVFILE=response.csv

(For the purposes of this exercise we're not so concerned with the
output frequency response, just seeing how many filters can be
implemented. For details of what these parameters mean to the FILTER
definition, see the documentation in the sc_dsp_filters module) 

Again, load the new binary in XTA and analyze the biquadAsm function::

  function: biquadAsm 
  stdcore[0] (node: 0, core: 0)
  Pass, Num Paths: 14
  Worst Case Timing:    4.3 us,    0.23 MHz,     433 thread cycles
  Required:     10.4 us,    0.10 MHz,    1040 thread cycles
  Slack:        6.1 us,    0.16 MHz,     607 thread cycles
  Min Core Frequency:      166 MHz

Notice that despite our previous estimate, we still haven't consumed
all the available time. In fact from this run of XTA, we could still
double the number of filters again and meet timing. This is due to the
function overhead that doesn't increase in proportion to the filter
complexity (in this case, functionality such as checking for
saturation, stack save/restore on function entry/exit and checking for
coefficient changes only happens once per function call while there is
an inner loop that iterates for the number of cascaded filters).

Given that new information, let's try 20 filters and see if we can
still meeet timing. Edit the makefile::

  coefficients:
	  make -f ../build_biquad_coefficients/Makefile.mk \
		FILTER='-min -20 -max 20 -step 1 -bits 27 -low 100 \
       -high 4000 -peaking 150 1 -peaking 200 1 -peaking 250 1 \
       -peaking 325 1 -peaking 500 1 -peaking 700 1 -peaking 1000 1 \
       -peaking 2000 1 -peaking 375 1 -peaking 575 1 -peaking 700 1 \
       -peaking 900 1 -peaking 1300 1 -peaking 2000 1' \
		INCLUDEFILE=src/coeffs.h \
		XCFILE=src/coeffs.xc \
		CSVFILE=response.csv

and rebuild as previously.

Again, we run XTA on the biquadAsm function::

  function: biquadAsm 
  stdcore[0] (node: 0, core: 0)
  Pass, Num Paths: 14
  Worst Case Timing:    9.7 us,    0.10 MHz,     967 thread cycles
  Required:     10.4 us,    0.10 MHz,    1040 thread cycles
  Slack:      730.0 ns,    1.37 MHz,      73 thread cycles
  Min Core Frequency:      371 MHz


So this shows we still meet timing with 20 biquad filters, but we
might only fit one more at best into the slack 73 thread cycles. This
is guaranteed to be worst case timing, so we can confident with 20
biquad filters we will always meet or better this time. In fact we
have only timed the biquadAsm function itself, in most real
applications we do need a small amount of logic around this function
call to receive and output samples to the threads around it.

Note again that this is based on a 400MHz device running with 4 threads used -
however it is straightforward to perform the same analysis in
other situations. The "thread cycles" information also makes it easy
to quickly calculate the changes if the thread count increases or
decreases. Taking the last case as an example:
If we had 8 threads with a 500 MHz part => 16ns instruction time.
10.4us / 16ns => 650 cycles
The thread cycles required for the filters are unchanged (967 thread
cycles), so we can quickly see that this wouldn't meet timing.

Working this backwards we can see that if 20 biquads take 967 cyles,
each filter is ~50 thread cycles. With 650 cycles available (10.4us at
500MHz), this would imply 13 biquad filters should fit.

Running one more recompilation we can then check this. XTA by
default will use the number of threads in the program to calculate
worst case timing. However this can be over-ridden to make it
calculate performance for any number of threads. In XDE in the Timing
perspective, the "Properties" option allows the number of threads to
be changed. On the command line interface, running "config threads
stdcore[0] 8" tells it to calculate for 8 threads. Similarly the
device frequency can be changed by "config freq 0 500".

With 13 filters configured, we get the following result::
  function: biquadAsm 
  stdcore[0] (node: 0, core: 0)
  Fail (timing violation), Num Paths: 14
  Worst Case Timing:   10.4 us,    0.10 MHz,     652 thread cycles
  Required:     10.4 us,    0.10 MHz,     650 thread cycles
  Failed, Violation:   32.0 ns,   31.25 MHz,       2 thread cycles
  Min Core Frequency:      501 MHz

In fact we just fail to meet timing by 2 thread cycles.
This is one of the situations where changing the buffering process
might allow us to just squeeze in the performance we need, but as said
previously, we still need to allow a few instructions for other
channel i/o within the thread, so we can conclude that 12 biquad
filters per channel is the limit for 2 channels at 48kHz sample
frequency when 8 threads are used in a design at 500MHz. An
alternative way of summarizing this it to say that approximately 5
MIPS are required per biquad filter for 2 channels at 48kHz. As
channel count or sample frequency increases, the available time will
decrease accordingly so either additional threads will be needed or
fewer operations can be performed per channel.


Saturation and distortion
-------------------------
One of the potential downsides of DSP is that it can introduce
unwanted distortion. While the implementation of the biquad filter
checks for saturation and overflow, high levels of processing can
still introduce unwanted artefacts.

The documentation for the biquad filter explains the significance of
the parameters passed in the Makefile. If multiple frequencies are
specified with gain increase, these overlaps can amplify and introduce
distortion.

One way to avoid this would be to only use gain reduction filters. An
alternative is to pre-process the samples and apply a reduction to all
samples before applying the EQ (say by right shifting a few bits), but
this may in turn introduce low level distortion through sample
accuracy loss. 



