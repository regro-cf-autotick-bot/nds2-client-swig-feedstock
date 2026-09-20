#!/bin/bash
#
# Build and install the Java bindings for the NDS2Client
#

set -ex
mkdir -p _build_java
cd _build_java

# python for testing
export PYTHON="${BUILD_PREFIX}/bin/python"

# set up cross compilation args
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  LIB_JVM="${BUILD_PREFIX}/lib/jvm"
  export CROSS_COMPILE_ARGS="
    -DJAVA_INCLUDE_PATH='${LIB_JVM}/include'
    -DJAVA_INCLUDE_PATH2='${LIB_JVM}/include/linux'
    -DJAVA_AWT_INCLUDE_PATH='${LIB_JVM}/include'
    -DJAVA_AWT_LIBRARY='${LIB_JVM}/lib/libjawt.so'
    -DJAVA_JVM_LIBRARY='${LIB_JVM}/lib/server/libjvm.so'
    -DCMAKE_C_FLAGS='-I${LIB_JVM}/include -I${LIB_JVM}/include/linux'
    -DCMAKE_CXX_FLAGS='-I${LIB_JVM}/include -I${LIB_JVM}/include/linux'
  "
fi

# configure
cmake \
  ${SRC_DIR} \
  ${CMAKE_ARGS} \
  ${CROSS_COMPILE_ARGS} \
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
  -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen:BOOL=yes \
  -DCMAKE_POLICY_VERSION_MINIMUM:STRING=3.5 \
  -DENABLE_SWIG_JAVA:BOOL=yes \
  -DENABLE_SWIG_MATLAB:BOOL=no \
  -DENABLE_SWIG_OCTAVE:BOOL=no \
  -DENABLE_SWIG_PYTHON2:BOOL=no \
  -DENABLE_SWIG_PYTHON3:BOOL=no \
  -DSWIG_EXECUTABLE:PATH="${BUILD_PREFIX}/bin/swig" \
;

# build
cmake --build java --parallel ${CPU_COUNT} --verbose

# install
cmake --build java --parallel ${CPU_COUNT} --verbose --target install

# test
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
export TEST_VERBOSE_LEVEL=100
ctest --parallel ${CPU_COUNT} --extra-verbose --output-on-failure
fi

# remove unnecessary testing files
rm -rvf ${PREFIX}/libexec/nds2-client/__pycache__
