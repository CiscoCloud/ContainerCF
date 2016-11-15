#! /bin/sh -ex

sed -i 's/peer-heartbeat-timeout/peer-heartbeat-interval/g' /var/vcap/jobs/etcd/bin/etcd_ctl
sed -i 's/peer-heartbeat-timeout/peer-heartbeat-interval/g' /var/vcap/jobs/etcd/templates/etcd_ctl.erb
