#!/bin/bash

set -e

SCRIPT_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"
cd "$SCRIPT_DIR/../tensorflow"

curl -L -o "$SCRIPT_DIR/bazel-0.19.2" \
  https://github.com/bazelbuild/bazel/releases/download/0.19.2/bazel-0.19.2-linux-x86_64

## prepare
  git co master ; git reset --hard HEAD
  patch -Np1 -i "${SCRIPT_DIR}/5b14577d42842871f1cb0eb8dfe77d32db1eb654.patch"
  patch -Np1 -i "${SCRIPT_DIR}/protobuf-version-bump.patch"
  patch -Np1 -i "${SCRIPT_DIR}/protobuf-python37-apply.patch"
  cp ${SCRIPT_DIR}/protobuf-python37.patch third_party/
  patch -Np1 -i "${SCRIPT_DIR}/explicitly_import_bazelrc.patch"
  export PYTHON_BIN_PATH=/usr/bin/python
  export USE_DEFAULT_PYTHON_LIB_PATH=1
  export TF_NEED_JEMALLOC=1
  export TF_NEED_KAFKA=0
  export TF_NEED_OPENCL_SYCL=0
  export TF_NEED_AWS=0
  export TF_NEED_GCP=0
  export TF_NEED_HDFS=0
  export TF_NEED_S3=0
  export TF_ENABLE_XLA=1
  export TF_NEED_GDR=0
  export TF_NEED_VERBS=0
  export TF_NEED_OPENCL=0
  export TF_NEED_MPI=0
  export TF_NEED_TENSORRT=0
  export TF_NEED_NGRAPH=0
  export TF_NEED_IGNITE=0
  export TF_NEED_ROCM=0
  export TF_SET_ANDROID_WORKSPACE=0
  export TF_DOWNLOAD_CLANG=0

## build
  export CC_OPT_FLAGS="-march=native"
  export TF_NEED_CUDA=0
  ./configure
  "${SCRIPT_DIR}/bazel-0.19.2" -c opt \
      //tensorflow:libtensorflow.so \
      //tensorflow/tools/pip_package:build_pip_package
  bazel-bin/tensorflow/tools/pip_package/build_pip_package ${SCRIPT_DIR}/tmp

## install tensorflow
  tensorflow/c/generate-pc.sh --prefix=/usr --version=1.12.0
  sudo install -Dm644 tensorflow.pc /usr/lib/pkgconfig/tensorflow.pc
  sudo install -Dm755 bazel-bin/tensorflow/libtensorflow.so \
                      /usr/lib/libtensorflow.so
  sudo install -Dm755 bazel-bin/tensorflow/libtensorflow_framework.so \
                      /usr/lib/libtensorflow_framework.so
  sudo install -Dm644 tensorflow/c/c_api.h /usr/include/tensorflow/c/c_api.h

## install python-tensorflow
  WHEEL_PACKAGE=$(find ${SCRIPT_DIR}/tmp -name "tensor*.whl")
  sudo pip install --ignore-installed --upgrade --root / $WHEEL_PACKAGE --no-dependencies

# vim:set ts=2 sw=2 et:
