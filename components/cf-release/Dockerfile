# Cloud Foundry on Marathon release
FROM shippedrepos-docker-sitd.bintray.io/sitd/cf-base

WORKDIR /root
ENV HOME /root

ENV CF_BRANCH v224

RUN apt-get update

ADD scripts/ /root/

RUN chmod u+x /root/bootstrap/*.sh; sync
RUN /root/bootstrap/clone_cf.sh
RUN /root/bootstrap/clone_nise_bosh.sh
RUN rm -r /root/bootstrap

# Is this required?
RUN apt-get -y remove --purge apparmor

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN chmod u+x /root/job/*.sh; sync
