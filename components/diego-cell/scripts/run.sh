#! /bin/bash

patch /var/vcap/packages/garden-linux/src/github.com/cloudfoundry-incubator/garden-linux/linux_backend/bin/setup.sh < /root/fragments/setup.sh.patch

IP_ADDRESS=$(ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1)
sed -i "s/ip:.*/ip: \"${IP_ADDRESS}\"/" /var/vcap/bosh/state.yml
sed -i "s/constant[(]value=\" \([0-9.]\+\)\{4\} \"[)]/constant(value=\" ${IP_ADDRESS} \")/" /var/vcap/jobs/metron_agent/config/syslog_forwarder.conf
sed -i "/#only RELP, UDP, and TCP are supported/ r /root/fragments/syslog_drain.frag" /var/vcap/jobs/metron_agent/config/syslog_forwarder.conf
sed -i "s/bind_addr\":\"\([0-9.]\+\)\{4\}\"/bind_addr\":\"${IP_ADDRESS}\"/" /var/vcap/jobs/consul_agent/config/config.json
sed -i "s/node_name\":\"[^\"]\+\"/node_name\":\"${MESOS_TASK_ID}\"/" /var/vcap/jobs/consul_agent/config/config.json
sed -i '/echo.*resolvconf/d' /var/vcap/jobs/consul_agent/bin/agent_ctl
sed -i 's/sed.*resolv.conf/echo \"DNS handled by Docker\"/' /var/vcap/jobs/consul_agent/bin/agent_ctl
sed -i 's/depends on/depends on garden,/' /var/vcap/jobs/rep/*_diego.rep.monitrc
sed -i "s/cellID=.*/cellID=${MESOS_TASK_ID} \\\/" /var/vcap/jobs/rep/bin/rep_ctl
sed -i "s/userns enabled/userns disabled/" /var/vcap/packages/garden-linux/src/github.com/cloudfoundry-incubator/garden-linux/linux_backend/skeleton/start.sh
sed -i "s/grep cpu:/grep cpu[,:]/"/var/vcap/packages/garden-linux/src/github.com/cloudfoundry-incubator/garden-linux/linux_backend/skeleton/destroy.sh

/root/job/start_all.sh
