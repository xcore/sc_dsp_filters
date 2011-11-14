DIR=../../sc_dsp_filters/build_fir_coefficients

all: $(DIR)/lib/makefir.jar
	java -jar $(DIR)/lib/makefir.jar $(FILTER)

$(DIR)/lib/makefir.jar: $(DIR)/src/makeFIR.java
	cd $(DIR); \
    javac src/MakeFIR.java ; \
	mv src/MakeFIR.class . ;\
	jar cfm lib/makefir.jar src/MANIFEST MakeFIR.class ;\
	rm MakeFIR.class
