#! /bin/bash

IP_ADDRESS=$(ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1)
sed -i "s/ip:.*/ip: \"${IP_ADDRESS}\"/" /var/vcap/bosh/state.yml
sed -i "s/constant[(]value=\" \([0-9.]\+\)\{4\} \"[)]/constant(value=\" ${IP_ADDRESS} \")/" /var/vcap/jobs/metron_agent/config/syslog_forwarder.conf
sed -i "s/listenAddr=\([0-9.]\+\)\{4\}/listenAddr=${IP_ADDRESS}/" /var/vcap/jobs/tps/bin/tps_listener_ctl
sed -i "s/17013/17023/" /var/vcap/jobs/tps/bin/tps_watcher_ctl
sed -i "s/bind_addr\":\"\([0-9.]\+\)\{4\}\"/bind_addr\":\"${IP_ADDRESS}\"/" /var/vcap/jobs/consul_agent/config/config.json
sed -i '/echo.*resolvconf/d' /var/vcap/jobs/consul_agent/bin/agent_ctl
sed -i 's/sed.*resolv.conf/echo \"DNS handled by Docker\"/' /var/vcap/jobs/consul_agent/bin/agent_ctl
sed -i "s|^advertise_peer_url.*|advertise_peer_url=\"http://${IP_ADDRESS}:7001\"|" /var/vcap/jobs/etcd/bin/etcd_bosh_utils.sh
sed -i "s|^advertise_client_url.*|advertise_client_url=\"http://${IP_ADDRESS}:4001\"|" /var/vcap/jobs/etcd/bin/etcd_bosh_utils.sh
sed -i "s/\([0-9.]\+\)\{4\}/${IP_ADDRESS}/" /var/vcap/jobs/tps/bin/dns_health_check

mkdir -p /var/vcap/jobs/file_server/packages/
ln -s /var/vcap/packages/buildpack_app_lifecycle/ /var/vcap/jobs/file_server/packages/
ln -s /var/vcap/packages/docker_app_lifecycle/ /var/vcap/jobs/file_server/packages/
ln -s /var/vcap/packages/windows_app_lifecycle/ /var/vcap/jobs/file_server/packages/

/root/job/start_all.sh
