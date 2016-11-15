# Cloud Foundry on Marathon release
FROM shippedrepos-docker-sitd.bintray.io/sitd/cf-manifest

WORKDIR /root

ENV HOME /root

RUN apt-get update
RUN apt-get -yq install silversearcher-ag libpath-tiny-perl libyaml-tiny-perl vim httpie
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

ADD scripts/ /root/
ADD fragments/ /root/fragments/
RUN chmod u+x /root/job/*.pl; sync
RUN chmod u+x /root/job/*.sh; sync
RUN chmod u+x /root/control/*.sh; sync

RUN mkdir bin
RUN wget -O bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64
RUN chmod +x bin/confd

RUN rm -f /etc/supervisor/conf.d/supervisord.conf
ADD etc/supervisord.conf /etc/supervisor/conf.d/
