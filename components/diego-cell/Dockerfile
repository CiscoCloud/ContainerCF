# Cloud Foundry Diego Cell for Marathon
FROM shippedrepos-docker-sitd.bintray.io/sitd/diego-manifests

WORKDIR /root
ENV HOME /root

RUN apt-get update && apt-get install -y netcat btrfs-tools

ADD scripts/ /root/
RUN chmod u+x /root/*.sh; sync
RUN chmod u+x /root/*/*.sh; sync

RUN /root/job/install.sh
RUN /root/job/cleanup.sh

ADD fragments/ /root/fragments
RUN wget https://storage.googleapis.com/golang/go1.5.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.5.3.linux-amd64.tar.gz && \
    rm go1.5.3.linux-amd64.tar.gz
ENV PATH $PATH:/usr/local/go/bin
ENV GOPATH /var/vcap/packages/garden-linux
RUN patch /var/vcap/packages/garden-linux/src/github.com/cloudfoundry-incubator/garden-linux/linux_container/cgroups_manager/cgroup_reader.go \
    < /root/fragments/cgroup_reader.go.patch
WORKDIR /var/vcap/packages/garden-linux/src/github.com/cloudfoundry-incubator/garden-linux
RUN make && \
    cp out/garden-linux /var/vcap/packages/garden-linux/bin/
RUN rm -rf /usr/local/go

WORKDIR /root

CMD /root/run.sh & /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
