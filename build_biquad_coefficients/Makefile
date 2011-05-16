all: ../../sc_dsp_filters/build_biquad_coefficients/src/makeCoeffs.c
	cc -DFILTER="\"$(FILTER)\"" -DINCLUDEFILE="\"$(INCLUDEFILE)\"" -DXCFILE="\"$(XCFILE)\"" -DCSVFILE="\"$(CSVFILE)\"" ../../sc_dsp_filters/build_biquad_coefficients/src/makeCoeffs.c -lm
	./a.out
