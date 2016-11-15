#! /bin/bash

IP_ADDRESS=$(ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1)
sed -i "s/ip:.*/ip: \"${IP_ADDRESS}\"/" /var/vcap/bosh/state.yml
sed -i "s/constant[(]value=\" \([0-9.]\+\)\{4\} \"[)]/constant(value=\" ${IP_ADDRESS} \")/" /var/vcap/jobs/metron_agent/config/syslog_forwarder.conf
sed -i "/#only RELP, UDP, and TCP are supported/ r /root/fragments/syslog_drain.frag" /var/vcap/jobs/metron_agent/config/syslog_forwarder.conf
sed -i "s|^advertise_peer_url.*|advertise_peer_url=\"http://${IP_ADDRESS}:7001\"|" /var/vcap/jobs/etcd/bin/etcd_bosh_utils.sh
sed -i "s|^advertise_client_url.*|advertise_client_url=\"http://${IP_ADDRESS}:4001\"|" /var/vcap/jobs/etcd/bin/etcd_bosh_utils.sh

/root/job/start_all.sh
