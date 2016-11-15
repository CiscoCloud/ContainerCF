#!/bin/bash -ex

ruby_version=2.2.3

if [ ! -d ~/.rbenv ]; then
    sudo apt-get -y install build-essential libreadline-dev libssl-dev zlib1g-dev git-core
    git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
    git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
    echo 'eval "$(rbenv init -)"' >> ~/.profile
fi

source ~/.profile

if ! (rbenv versions | grep -q ${ruby_version}); then
    rbenv install ${ruby_version}
fi
rbenv local ${ruby_version}

gem install bundler --no-rdoc --no-ri
rbenv rehash
