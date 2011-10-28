TARGET = XK-1

APP_NAME =

XCC_FLAGS = -O2

USED_MODULES = module_fir

#=============================================================================
# The following part of the Makefile includes the common build infrastructure
# for compiling XMOS applications. You should not need to edit below here.


# Use the main Makefile from module_xcommon
-include ../module_xcommon/build/Makefile.common
-include ../../xcommon/module_xcommon/build/Makefile.common

# The final target of the build. This is usually dependent on a binary file
# in the $(BIN_DIR) directory e.g.
#
#  all : $(BIN_DIR)/my_app.xe

all: coefficients $(BIN_DIR)/$(APP_NAME).xe
	@echo Build Complete

coefficients:
	make -f ../../sc_dsp_filters/build_fir_coefficients/Makefile \
		FILTER='-low 250 -high 2500  -n 281 -hamming -xc src/coeffs.xc -csv bin/response.csv'

clean: clean_common
	rm MakeFIR.class
