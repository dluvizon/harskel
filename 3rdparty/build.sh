#!/bin/bash

pushd libsvm
  make
popd
pushd vlfeat-0.9.20
  make
popd

