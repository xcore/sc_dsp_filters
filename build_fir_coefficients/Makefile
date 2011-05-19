all: MakeFIR.class
	java MakeFIR $(FILTER)

MakeFIR.class: ../../sc_dsp_filters/build_fir_coefficients/src/makeFIR.java
	javac ../../sc_dsp_filters/build_fir_coefficients/src/MakeFIR.java
	mv ../../sc_dsp_filters/build_fir_coefficients/src/MakeFIR.class .
