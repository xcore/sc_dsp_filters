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

To Do
=====

* Optimised biquad
* Optimised FIR
* On-the-fly computation of coefficients
* Saturate results
* Optional dithering

Firmware Overview
=================

This repo intends to store a set of algorithms to perform standard DSP
functions. At present, only a cascaded biquad is implemented that can
implement, for example, an audio equaliser. It comes with a program that
generates biquad coefficients and a response curve. Coefficients and
response curves are computed based on algorithms by Robert Bristow-Johnson.

The current versions are written for readability - less readable versions
to follow.

Known Issues
============

* Makefile should invoke biquad generator properly - currently relies on
  gcc, and currently recreates files unnecessarily.

Required Repositories
================

* xcommon git\@github.com:xcore/xcommon.git

Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any issues submitted as at the discretion of the maintainer for this line.
