FROM ubuntu:vivid

RUN apt-get update && apt-get install -y curl httpie jq perl \
    build-essential autoconf automake libtool \
    libpath-tiny-perl libfile-path-perl libyaml-tiny-perl silversearcher-ag \
    wget git mercurial bzr
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

RUN cpan -T CPAN
RUN cpan -T Test::Most Test::Files File::Spec

RUN groupadd vcap --gid 1000

WORKDIR /root

RUN wget https://storage.googleapis.com/golang/go1.5.2.linux-amd64.tar.gz
RUN tar -C /usr/local -xzf go1.5.2.linux-amd64.tar.gz
RUN rm go1.5.2.linux-amd64.tar.gz
ENV PATH $PATH:/usr/local/go/bin
RUN mkdir /root/go
ENV GOPATH /root/go

RUN wget -O cf-cli.deb 'https://cli.run.pivotal.io/stable?release=debian64&version=6.19.0&source=github-rel'
RUN dpkg -i cf-cli.deb

RUN go get -d github.com/cloudfoundry/cf-acceptance-tests
