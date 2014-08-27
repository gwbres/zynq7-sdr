mkdir -p /usr/include/test1/test1/swig
mkdir -p /usr/lib/python2.7/site-packages/test1
mkdir -p /usr/share/gnuradio/grc/blocks

cp include/test1/api.h /usr/include/test1/
cp include/test1/toto.h /usr/include/test1/
cp include/test1/dds_fpga.h /usr/include/test1/

cp build_cross/lib/libgnuradio-test1.so /usr/lib/
cp build_cross/swig/_test1_swig.so /usr/lib/python2.7/site-packages/test1/
cp build_cross/swig/test1_swig.py /usr/lib/python2.7/site-packages/test1/
cp build_cross/swig/test1_swig.pyc /usr/lib/python2.7/site-packages/test1/
cp build_cross/swig/test1_swig.pyo /usr/lib/python2.7/site-packages/test1/

cp swig/test1_swig.i /usr/include/test1/test1/swig/
cp build_cross/swig/test1_swig_doc.i /usr/include/test1/test1/swig/

cp python/__init__.py /usr/lib/python2.7/site-packages/test1/
cp build_cross/python/__init__.py*  /usr/lib/python2.7/site-packages/test1/

cp grc/test1_*.xml /usr/share/gnuradio/grc/blocks/
