# CF on Marathon Base Image
FROM ubuntu:vivid

WORKDIR /root
ENV HOME /root

ENV TERM vt100

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN echo Etc/UTC > /etc/timezone && \
		dpkg-reconfigure --frontend noninteractive tzdata

RUN apt-get update && \
    apt-get -yq install supervisor libcgroup1 curl sudo \
    dnsmasq net-tools inetutils-ping aufs-tools libdevmapper-dev libapparmor-dev \
    rsyslog debootstrap cron

RUN sed -i 's/^mesg n/tty -s \&\& mesg n/g' /root/.profile

ADD scripts/install_ruby.sh /root/install_ruby.sh
RUN chmod u+x /root/*.sh; sync && \
    /root/install_ruby.sh

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/log/supervisor
