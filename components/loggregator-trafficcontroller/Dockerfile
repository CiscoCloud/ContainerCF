# Cloud Foundry Loggregator Traffic Controller for Marathon
FROM shippedrepos-docker-sitd.bintray.io/sitd/cf-control

WORKDIR /root

ENV HOME /root
ENV CF_JOB loggregator_trafficcontroller

ADD scripts/run.sh /root/
RUN chmod u+x /root/*.sh

EXPOSE 18080

RUN /root/job/install.sh
RUN /root/job/cleanup.sh

CMD /root/run.sh & /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
