#!/bin/sh
export GR_DONT_LOAD_PREFS=1
export srcdir=/home/guillaume/tf-cadence/gnuradio/zedboard/gr-test1WithBufLen/lib
export PATH=/home/guillaume/tf-cadence/gnuradio/zedboard/gr-test1WithBufLen/build_cross/lib:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH
export PYTHONPATH=$PYTHONPATH
test-test1 
