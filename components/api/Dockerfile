# Cloud Foundry Cloud Controller for Marathon
FROM shippedrepos-docker-sitd.bintray.io/sitd/cf-control

RUN apt-get update && apt-get install -y netcat

WORKDIR /root

ENV HOME /root
ENV CF_JOB api

EXPOSE 9022

RUN /root/job/install.sh
RUN /root/job/cleanup.sh

ADD scripts/run.sh /root/
RUN chmod u+x /root/*.sh

CMD /root/run.sh & /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
