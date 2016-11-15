# Cloud Foundry Diego for Marathon
FROM shippedrepos-docker-sitd.bintray.io/sitd/diego-manifests

WORKDIR /root
ENV HOME /root

RUN apt-get update && apt-get install -y netcat

ADD scripts/ /root/
RUN chmod u+x /root/*.sh; sync
RUN chmod u+x /root/*/*.sh; sync

RUN /root/job/install.sh
RUN /root/job/cleanup.sh

WORKDIR /root

CMD /root/run.sh & /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
