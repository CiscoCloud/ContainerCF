#!/bin/bash -ex

source ~/.profile

ETCD_URL=${ETCD_URL:-https://github.com/cloudfoundry-incubator/etcd-release}
ETCD_VERSION=${ETCD_VERSION:-master}

if [ ! -d etcd-release ]; then
  git clone ${ETCD_URL} etcd-release
fi

(
  cd etcd-release
  git checkout ${ETCD_VERSION}
  git submodule update --init --recursive
)
