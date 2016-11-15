# Cloud Foundry Postgres for Marathon
FROM shippedrepos-docker-sitd.bintray.io/sitd/cf-control

WORKDIR /root

ENV HOME /root
ENV CF_JOB postgres

ADD scripts/run.sh /root/
ADD scripts/run_first.sh /root/
RUN chmod u+x /root/*.sh

EXPOSE 5524

RUN /root/job/install.sh
RUN /root/job/cleanup.sh
RUN /root/run_first.sh

CMD /root/run.sh & /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
