DSP filters
...........

:Stable release:  unreleased

:Status:  first version

:Maintainer:  https://github.com/henkmuller

:Description:  A collection of standard DSP building blocks


Key Features
============

* Generic cascaded biquad filter
* Generator for filter values
* Generic FIR
* Asynchronous Sample Rate converter

To Do
=====

* Optimised biquad
* Optimised FIR
* On-the-fly computation of coefficients
* Optional dithering

Firmware Overview
=================

This repo intends to store a set of algorithms to perform standard DSP
functions, enabling people to implement, for example, graphic equalisers or
sample rate converters. At present, only a cascaded biquad and a FIR filter
are implemented, together with programs to compute coefficients and
response curves. Coefficients and
response curves for the biquad are computed based on algorithms by Robert
Bristow-Johnson. 

The current FIR code is written for readability - less readable
(more efficient) versions to follow. The generic versions check on overflow
and saturate (intermediate) results.


Known Issues
============

* Makefile should invoke biquad generator properly - currently relies on
  java and javac, and currently recreates files unnecessarily.

Required Repositories
================

* xcommon git\@github.com:xcore/xcommon.git

Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to
any issues submitted as at the discretion of the maintainer for this line.

