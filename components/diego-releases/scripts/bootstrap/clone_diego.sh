#!/bin/bash -ex

source ~/.profile

DIEGO_URL=${DIEGO_URL:-https://github.com/cloudfoundry-incubator/diego-release}
DIEGO_VERSION=${DIEGO_VERSION:-master}

if [ ! -d diego-release ]; then
  git clone ${DIEGO_URL} diego-release
fi

(
  cd diego-release
  git checkout ${DIEGO_VERSION}
  git submodule update --init --recursive
)
