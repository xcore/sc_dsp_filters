all: MakeCoeffs.class
	java MakeCoeffs $(FILTER) -h $(INCLUDEFILE) -xc $(XCFILE) -csv $(CSVFILE)

MakeCoeffs.class: ../../sc_dsp_filters/build_biquad_coefficients/src/MakeCoeffs.java
	javac  ../../sc_dsp_filters/build_biquad_coefficients/src/MakeCoeffs.java
	cp ../../sc_dsp_filters/build_biquad_coefficients/src/MakeCoeffs*.class .
