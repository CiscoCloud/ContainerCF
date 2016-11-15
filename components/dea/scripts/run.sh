#! /bin/bash

awk 'NR>1 {print $1}' /proc/cgroups |
while read -r a
do
  b="/tmp/warden/cgroup/$a"
  mkdir -p "$b"
done

mount -tcgroup -operf_event cgroup:perf_event /tmp/warden/cgroup/perf_event
mount -tcgroup -omemory cgroup:memory /tmp/warden/cgroup/memory
mount -tcgroup -oblkio cgroup:blkio /tmp/warden/cgroup/blkio
mount -tcgroup -ohugetlb cgroup:hugetlb /tmp/warden/cgroup/hugetlb
mount -tcgroup -onet_cls,net_prio cgroup:net_prio /tmp/warden/cgroup/net_prio
mount -tcgroup -onet_cls,net_prio cgroup:net_cls /tmp/warden/cgroup/net_cls
mount -tcgroup -ocpu,cpuacct cgroup:cpu /tmp/warden/cgroup/cpu
mount -tcgroup -ocpu,cpuacct cgroup:cpuacct /tmp/warden/cgroup/cpuacct
mount -tcgroup -ocpuset cgroup:cpuset /tmp/warden/cgroup/cpuset
mount -tcgroup -odevices cgroup:devices /tmp/warden/cgroup/devices
mount -tcgroup -ofreezer cgroup:perf_event /tmp/warden/cgroup/freezer

IP_ADDRESS=$(ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1)
sed -i "s/ip:.*/ip: \"${IP_ADDRESS}\"/" /var/vcap/bosh/state.yml
sed -i "s/constant[(]value=\" \([0-9.]\+\)\{4\} \"[)]/constant(value=\" ${IP_ADDRESS} \")/" /var/vcap/jobs/metron_agent/config/syslog_forwarder.conf
sed -i "/#only RELP, UDP, and TCP are supported/ r /root/fragments/syslog_drain.frag" /var/vcap/jobs/metron_agent/config/syslog_forwarder.conf
sed -i "s|grep -q '/instance' /proc/self/cgroup|grep -q '/docker' /proc/self/cgroup|g" /var/vcap/packages/common/utils.sh
sed -i "s|\(/var/vcap/jobs/dea_next/bin/dea_ctl stop\" with timeout\) [[:digit:]]\+|\1 600|" /var/vcap/jobs/dea_next/*.monitrc
sed -i "/stop)/a /root/drain.sh" /var/vcap/jobs/dea_next/bin/dea_ctl
sed -i "s/CONFD_NODE_PLACEHOLDER/${CONFD_NODE}/" /root/drain.sh

/root/job/start_all.sh
