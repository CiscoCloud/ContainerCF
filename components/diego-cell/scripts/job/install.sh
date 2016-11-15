#!/bin/sh -ex

. ~/.profile
cd /root

(
  NISE_IP_ADDRESS=${NISE_IP_ADDRESS:-`ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1`}
  cd nise_bosh
  sudo env PATH=$PATH bundle exec ./bin/nise-bosh --keep-monit-files -y ../diego-release ../manifests/nise-diego.yml diego_cell -n ${NISE_IP_ADDRESS}
  sudo env PATH=$PATH bundle exec ./bin/nise-bosh --keep-monit-files -y ../cf-release ../manifests/nise-diego-cf-components.yml cf_components_diego_cell -n ${NISE_IP_ADDRESS}
  sudo env PATH=$PATH bundle exec ./bin/nise-bosh --keep-monit-files -y -r ../garden-linux-release/releases/garden-linux/garden-linux-${GARDEN_LINUX_VERSION#v}.yml ../garden-linux-release ../manifests/nise-diego-garden.yml garden -n ${NISE_IP_ADDRESS}

  find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_fin_timeout/a echo' ;
  find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_tw_recycle/a echo' ;
  find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_tw_reuse/a echo' ;
  find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/net.ipv4.neigh.default.gc_thresh/a echo' ;

  find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_fin_timeout/d' ;
  find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_tw_recycle/d' ;
  find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/tcp_tw_reuse/d' ;
  find /var/vcap/jobs/*/bin/ -type f | xargs sed -i '/net.ipv4.neigh.default.gc_thresh/d' ;

  find /root/diego-release/.final_builds/packages/*/ -type f -iname "*.tgz" -print0 | xargs -0 -I {} truncate {} --size 0
  find /root/cf-release/.final_builds/packages/*/ -type f -iname "*.tgz" -print0 | xargs -0 -I {} truncate {} --size 0
  find /root/garden-linux-release/.final_builds/packages/*/ -type f -iname "*.tgz" -print0 | xargs -0 -I {} truncate {} --size 0
)
