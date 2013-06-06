TARGET = xp_skc_su1.xn
APP_NAME = app_slicekit_fbnc_demo
USED_MODULES = module_i2c_single_port module_i2s_loopback module_i2s_master

XCC_FLAGS = -O3 -g -Wall $(CLFLAGS)

# The VERBOSE variable, if set to 1, enables verbose output from the make system.
VERBOSE = 0

#=============================================================================
# The following part of the Makefile includes the common build infrastructure
# for compiling XMOS applications. You should not need to edit below here.

XMOS_MAKE_PATH ?= ../..
include $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common
