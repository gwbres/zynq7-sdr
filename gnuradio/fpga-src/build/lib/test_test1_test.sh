#!/bin/sh
export GR_DONT_LOAD_PREFS=1
export srcdir=/mnt/gr-test1/lib
export PATH=/mnt/gr-test1/build/lib:$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH
export DYLD_LIBRARY_PATH=$LD_LIBRARY_PATH:$DYLD_LIBRARY_PATH
export PYTHONPATH=$PYTHONPATH
test-test1 
