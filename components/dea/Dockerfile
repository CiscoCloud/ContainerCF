# Cloud Foundry DEA for Marathon
FROM shippedrepos-docker-sitd.bintray.io/sitd/cf-control

WORKDIR /root

ENV HOME /root
ENV CF_JOB dea

RUN wget -O /tmp/consul.zip https://releases.hashicorp.com/consul/0.6.0/consul_0.6.0_linux_amd64.zip && \
    unzip /tmp/consul.zip -d /root/bin/ && \
    rm /tmp/consul.zip

ADD scripts/ /root/
RUN chmod u+x /root/*.sh

RUN /root/job/install.sh
RUN /root/job/cleanup.sh

RUN chmod +x /var/vcap/jobs/dea_next/templates/deterministic_drain.rb

CMD /root/run.sh & /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
