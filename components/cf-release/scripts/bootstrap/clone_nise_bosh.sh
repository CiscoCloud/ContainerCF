#!/bin/bash -ex

source ~/.profile

if [ ! -d nise_bosh ]; then
  git clone https://github.com/nttlabs/nise_bosh.git

  (
    cd nise_bosh

    if [ "" != "$NISE_BOSH_REV" ]; then
      git checkout $NISE_BOSH_REV
    fi

    echo "Using Nise BOSH revision: `git rev-list --max-count=1 HEAD`"
  )
else
  echo "'nise_bosh' directory is not empty. Skipping cloning..."
fi

(
  cd nise_bosh

  sed -i '/apt-get update/d' ./bin/init
  sed -i '/exit 1/d' ./bin/init
  #openpkg appears down. Revert to mmonit.com
  #sed -i 's,mmonit.com/monit/dist,download.openpkg.org/components/cache/monit,' ./bin/init

  sudo ./bin/init
  sudo apt-get install -y libmysqlclient-dev libpq-dev

  # Update eventmachine for compatibility with Ruby 2.2.3
  bundle update eventmachine

  bundle install
)
