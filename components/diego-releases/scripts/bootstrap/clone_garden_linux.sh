#!/bin/bash -ex

source ~/.profile

GARDEN_LINUX_URL=${GARDEN_LINUX_URL:-https://github.com/cloudfoundry-incubator/garden-linux-release}
GARDEN_LINUX_VERSION=${GARDEN_LINUX_VERSION:-master}

if [ ! -d garden-linux-release ]; then
  git clone ${GARDEN_LINUX_URL} garden-linux-release
fi

(
  cd garden-linux-release
  git checkout ${GARDEN_LINUX_VERSION}
  git submodule update --init --recursive
)
