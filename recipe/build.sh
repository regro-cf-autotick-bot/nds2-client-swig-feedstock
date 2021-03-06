#!/bin/bash

mkdir -p build
pushd build

if [ "${PY3K}" -eq 1 ]; then
	_PYTHON_BUILD_OPTS="-DENABLE_SWIG_PYTHON2=no -DENABLE_SWIG_PYTHON3=yes -DPYTHON3_EXECUTABLE=${PYTHON}"
else
	_PYTHON_BUILD_OPTS="-DENABLE_SWIG_PYTHON3=no -DENABLE_SWIG_PYTHON2=yes -DPYTHON2_EXECUTABLE=${PYTHON}"
fi

cmake .. \
	-DCMAKE_INSTALL_PREFIX=${PREFIX} \
	-DCMAKE_PREFIX_PATH=${PREFIX}/bin \
	-DWITH_SASL=${PREFIX} \
	-DWITH_GSSAPI=no \
	-DENABLE_SWIG_JAVA=false \
	-DENABLE_SWIG_MATLAB=false \
	-DENABLE_SWIG_OCTAVE=false \
	${_PYTHON_BUILD_OPTS} \
	-DPYTHON_NUMPY_INCLUDE_PATH=${SP_DIR}/numpy/core/include \
	-DPYTHON_MODULE_INSTALL_DIR=${SP_DIR} \
	-DPYTHON_EXTMODULE_INSTALL_DIR=${SP_DIR}

cmake --build . --config Release -- -j${CPU_COUNT}
ctest -V
cmake --build . -- install

popd
