#!/bin/bash

set -e

SCRIPT_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"
cd "$SCRIPT_DIR/grpc"

## build
  make $MAKEFLAGS prefix=/usr -j$(nproc)

## install
  _install_dir() (
    cd "$2"
    sudo find . -type f -exec install "-Dm$1" '{}' "/$3/{}" ';'
    sudo find . -type l -exec cp -a '{}' "/$3/{}" ';'
  )
  _install_dir 755 bins/opt usr/bin
  _install_dir 755 libs/opt usr/lib
  sudo chmod 644 /usr/lib/*.a
  _install_dir 644 include usr/include
  sudo install -Dm644 etc/roots.pem "/usr/share/grpc/roots.pem"
