########################################################################
# Toolchain file for building native on a ARM Cortex A8 w/ NEON
# Usage: cmake -DCMAKE_TOOLCHAIN_FILE=<this file> <source directory>
########################################################################
# Target system
set(CMAKE_SYSTEM_NAME Linux)

#set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_CXX_COMPILER_FORCED TRUE)
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER arm-poky-linux-gnueabi-g++)
set(CMAKE_C_COMPILER  arm-poky-linux-gnueabi-gcc)
set(CMAKE_CXX_FLAGS "-march=armv7-a -mtune=cortex-a8 -mfpu=neon -mfloat-abi=softfp" CACHE STRING "" FORCE)
set(CMAKE_C_FLAGS ${CMAKE_CXX_FLAGS} CACHE STRING "" FORCE) #same flags for C sources
set(toolchain_path 	/opt/poky/1.5+snapshot/sysroots/x86_64-pokysdk-linux)
set(CMAKE_FIND_ROOT_PATH /opt/poky/1.5+snapshot/sysroots/x86_64-pokysdk-linux)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY /opt/poky/1.5+snapshot/sysroots/x86_64-pokysdk-linux/usr/lib)
set(GNURADIO_RUNTIME_INCLUDE_DIRS /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/include)
set(GNURADIO_RUNTIME_LIBRARY_DIRS /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/lib)
set(GNURADIO_RUNTIME_LIBRARIES /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/lib/libgnuradio-runtime.so)

set(DOXYGEN_DOT_EXECUTABLE FALSE)
set(DOXYGEN_EXECUTABLE FALSE)
set(Boost_INCLUDE_DIRS /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/include/boost)
set(BOOST_LIBRARYDIR /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/lib)
set(CPPUNIT_FOUND TRUE)
set(CPPUNIT_INCLUDE_DIRS /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/include)
set(CPPUNIT_INCLUDE_DIR /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/include)
set(CPPUNIT_LIBDIR /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/include)
set(PC_CPPUNIT_INCLUDE_DIR /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/include)
set(PC_CPPUNIT_LIBDIR /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/lib)
set(PC_GNURADIO_RUNTIME_INCLUDEDIR /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/include)

set(PYTHONLIBS_FOUND TRUE)
#set(PYTHON_LIBRARIES /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/lib)
set(PYTHON_INCLUDE_PATH /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/include/python2.7)
set(PYTHON_INCLUDE_DIRS /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/include/python2.7)
set(PYTHON_LIBRARY /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/lib/libpython2.7.so)
set(PYTHON_INCLUDE_DIR /opt/poky/1.5+snapshot/sysroots/armv7a-vfp-neon-poky-linux-gnueabi/usr/include/python2.7)
