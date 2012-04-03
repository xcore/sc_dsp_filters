SPHINX_PROJECT_NAME=DSP filtering
VERSION=0v1
DOXYGEN_DIRS=../../sc_dsp_filters/module_cascading_biquad ../../sc_dsp_filters/module_asrc
SOURCE_INCLUDE_DIRS=../../sc_dsp_filters
XDOC_DIR ?= ../../xdoc
include $(XDOC_DIR)/Makefile.inc

all: html pdf
	@if [ ! -d ../../sc_dsp_filters_gh_pages ] ; then echo '**** no gh_pages checked out ****'; exit 0; else cp -r _build/html/* ../../sc_dsp_filters_gh_pages/; cp -r _build/html/.doctrees ../../sc_dsp_filters_gh_pages/; echo 'HTML files copied to sc_dsp_filters_gh_pages'; echo 'Now go to sc_dsp_filters_gh_pages, commit, and push to publish the documentation'; fi
