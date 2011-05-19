# The TARGET variable determines what target system the application is 
# compiled for. It either refers to an XN file in the source directories
# or a valid argument for the --target option when compiling.

TARGET = XK-1

# The APP_NAME variable determines the name of the final .xe file. It should
# not include the .xe postfix. If left blank the name will default to 
# the project name

APP_NAME = app_example_biquad

# The flags passed to xcc when building the application
# You can also set the following to override flags for a particular language:
#
#    XCC_XC_FLAGS, XCC_C_FLAGS, XCC_ASM_FLAGS, XCC_CPP_FLAGS
#
# If the variable XCC_MAP_FLAGS is set it overrides the flags passed to 
# xcc for the final link (mapping) stage.

XCC_FLAGS = -O2

# The USED_MODULES variable lists other module used by the application. 

USED_MODULES = module_cascading_biquad

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
	make -f ../../sc_dsp_filters/build_biquad_coefficients/Makefile \
		FILTER='-min -20 -max 20 -step 1 -bits 27 -low 250 -high 4000' \
		INCLUDEFILE=src/coeffs.h \
		XCFILE=src/coeffs.xc \
		CSVFILE=bin/response.csv

#		FILTER='-min -12 -max 12 -step 1 -bits 27 -low 15.625 -peaking 31.25 1 -peaking 62.5 1 -peaking 125 1 -peaking 250 1 -peaking 500 1 -peaking 1000 1 -peaking 2000 1 -peaking 4000 1 -high 8000' \

clean: clean_common
	rm MakeCoeffs.class MakeCoeffs?F.class