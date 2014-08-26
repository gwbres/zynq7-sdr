#!/bin/sh
export GR_DONT_LOAD_PREFS=1
export srcdir=/home/guillaume/tmp/zedboard/gr-test1WithBufLen/lib
export PATH=/home/guillaume/tmp/zedboard/gr-test1WithBufLen/build/lib:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH
export PYTHONPATH=$PYTHONPATH
test-test1 
