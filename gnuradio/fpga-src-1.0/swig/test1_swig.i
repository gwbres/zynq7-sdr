/* -*- c++ -*- */

#define TEST1_API

%include "gnuradio.i"			// the common stuff

//load generated python docstrings
%include "test1_swig_doc.i"

%{
#include "test1/toto.h"
#include "test1/dds_fpga.h"
%}


%include "test1/toto.h"
GR_SWIG_BLOCK_MAGIC2(test1, toto);
%include "test1/dds_fpga.h"
GR_SWIG_BLOCK_MAGIC2(test1, dds_fpga);
