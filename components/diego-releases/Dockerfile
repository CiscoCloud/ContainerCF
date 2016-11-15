# Cloud Foundry Diego Releases for Marathon
FROM shippedrepos-docker-sitd.bintray.io/sitd/cf-control

WORKDIR /root
ENV HOME /root

ENV DIEGO_VERSION v0.1440.0
ENV ETCD_VERSION v18
ENV GARDEN_LINUX_VERSION v0.326.0

ADD scripts/ /root/
RUN chmod u+x /root/*.sh; sync
RUN chmod u+x /root/*/*.sh; sync
RUN /root/bootstrap/clone_diego.sh
RUN /root/bootstrap/clone_etcd.sh
RUN /root/bootstrap/clone_garden_linux.sh
RUN rm -r /root/bootstrap

