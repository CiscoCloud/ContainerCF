#!/bin/bash -ex

source ~/.profile

CF_URL=${CF_URL:-https://github.com/cloudfoundry/cf-release}
CF_BRANCH=${CF_BRANCH:-master}

if [ ! -d cf-release ]; then
    git clone ${CF_URL} cf-release
fi

(
  cd cf-release
  git checkout ${CF_BRANCH}
  git submodule update --init --recursive
)
