#! /bin/sh -ex

sed -i '/kernel.shmmax/d' /var/vcap/jobs/postgres/bin/postgres_ctl
