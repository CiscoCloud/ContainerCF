# Cloud Foundry HM9000 for Marathon
FROM shippedrepos-docker-sitd.bintray.io/sitd/cf-control

WORKDIR /root

ENV HOME /root
ENV CF_JOB hm9000

ADD scripts/run.sh /root/
RUN chmod u+x /root/*.sh

EXPOSE 5155

RUN /root/job/install.sh
RUN /root/job/cleanup.sh

CMD /root/run.sh & /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
