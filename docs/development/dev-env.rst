Mesos Dev Cluster
=================
Provided here for reference, the following instructions were used to check our initial Mesos/Marathon environments, which were tied into our Concourse pipeline.
A lot of this information is now old (~12 months) and Mesos deployments are likley easier, however it is provided here for reference.

OpenDCOS is a very easily install (in comparison) however only run's on CentOS, which causes issues with the version of CloudFoundry we have so far run through the pipeline (same as the historical CentOS Stemcell issues running CF).


Pre-Requisite Instructions
--------------------------
This guide assumes you already have an OpenSource Mesos cluster with Marathon version >= 0.14.0 ready to go.

You will need at least 20Gb of available RAM and 8 available CPUs across your Mesos cluster in order to run Cloud Foundry comfortably. If you're planning on pushing more than a few test apps then we recommend you allocate more RAM and increase the number of DEAs or Diego cells (see cf_parameters instructions later in this README).

We also assume that those machines are running Ubuntu 15.04 (Vivid) or newer. We have not tested for anything else, therefore if you are not running Vivid we recommend that you upgrade before you begin. (Skip this step if you are already running >= 15.04.)

$ apt-get update && apt-get install update-manager-core
$ vi /etc/update-manager/release-upgrades
Prompt=normal
$ do-release-upgrade
n.b. the above step takes a very long time.

Mesos nodes
-----------

You can install Cloud Foundry into a Mesos cluster of any size, from a single node upwards. However some components need a fixed IP address. For the rest of this guide we'll refer to the slave node that runs these components as the main node. You can elect any of your Mesos slave nodes to be your main node, just be consistent once you've picked one!

Installation
~~~~~~~~~~~~

Docker (all nodes)

.. code-block:: c
    $ sudo apt-get update
    $ sudo apt-get -y install libdevmapper* libudev* udev aufs-tools libdevmapper-event* libudev-dev libdevmapper-dev \
      golang make gcc btrfs-tools libsqlite3-dev overlayroot debootstrap linux-image-generic curl vim httpie unzip jq
    $ sudo curl -sSL https://get.docker.com/ | sh
    $ sudo systemctl enable docker # start docker on boot
    $ sudo usermod -aG docker ubuntu # will let you run docker without being root, takes effect on restart

    $ sudo vim /lib/systemd/system/docker.service
      [Service]
      Type=notify
      EnvironmentFile=/etc/default/docker
      ExecStart=/usr/bin/docker daemon -H fd:// $DOCKER_OPTS

    $ sudo vim /etc/default/docker
      DOCKER_OPTS="-s devicemapper --storage-opt dm.basesize=30G"

    $ sudo systemctl daemon-reload
    $ sudo service docker restart
    $ sudo docker info
      Storage Driver: devicemapper
       Udev Sync Supported: true

Mesos (all nodes)

Ensure Mesos knows to use the correct containerizers and has a sufficiently long registration timeout for starting Docker containers.

.. code-block:: c
    $ sudo mkdir /etc/mesos-slave/resources
    $ sudo vim /etc/mesos-slave/resources/ports
      [80, 443, 2379, 4001, 8300, 8500]
    $ sudo vim /etc/mesos-slave/containerizers
      docker,mesos
    $ sudo vim /etc/mesos-slave/executor_registration_timeout
      10mins
    $ sudo service mesos-slave restart


Flannel (all nodes)

Cloud Foundry in Docker dev cluster uses a Flannel overlay network to communicate across Mesos nodes.

.. code-block:: c
    $ cd /tmp
    $ git clone https://github.com/coreos/flannel.git
    $ cd flannel
    $ sudo docker run -v `pwd`:/opt/flannel -i -t google/golang /bin/bash -c "cd /opt/flannel && ./build"
    $ sudo cp bin/flanneld /usr/local/bin/
    N.B. if you later encounter networking issues, and have previously used (or still use) other overlay networks, check your iptables - you may need to purge them.

Etcd (main node only)

Necessary to store subnet information for Flannel.

.. code-block:: c
    $ cd /tmp
    $ curl -L https://github.com/coreos/etcd/releases/download/v2.2.2/etcd-v2.2.2-linux-amd64.tar.gz -o etcd-v2.2.2-linux-amd64.tar.gz
    $ tar xzvf etcd-v2.2.2-linux-amd64.tar.gz
    $ sudo cp etcd-v2.2.2-linux-amd64/etcdctl /usr/local/bin/
    $ rm -r etcd-v2.2.2-linux-amd64

Consul (main node only)

Cloud Foundry jobs make use of confd backed by Consul to enable dynamic provisioning across your Mesos cluster.

.. code-block:: c

    $ wget -O /tmp/consul.zip https://releases.hashicorp.com/consul/0.6.0/consul_0.6.0_linux_amd64.zip
    $ sudo unzip /tmp/consul.zip -d /usr/local/bin/
    $ rm /tmp/consul.zip

Grub (all nodes)

.. code-block:: c
    $ sudo vim /etc/default/grub
      GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"

    $ sudo update-grub
    $ sudo reboot now


Troubleshooting
---------------
The following items were FAQ's in our initial Mesos/Marathon build pipeline environment.

TCP or HTTP errors on login
~~~~~~~~~~~~~~~~~~~~~~~~~~~
cf api or cf login gives a 503, 502 or 404 error, or Error performing request: Get http://api.<your domain>: dial tcp <your node ip>:80: getsockopt: connection refused This is most likely because a CF component is not ready yet. Give things a bit more time to stabilise and try again. If the error persists for longer than 10 minutes or then the fastest solution is to delete and redeploy.

cf push hangs indefinitely
~~~~~~~~~~~~~~~~~~~~~~~~~~
The API and DEAs are still wiring themselves together. Quit the push, delete the app, wait a little and try again.

Stack not found error
~~~~~~~~~~~~~~~~~~~~~
CFoundry::StackNotFound: 250003: The stack could not be found: The requested app stack cflinuxfs2 is not available on this system The DEAs have not registered correctly with the API. Restart the API job using Marathon.

Instances information unavailable error
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Could not fetch instance count: Server error, status code: 503, error code: 220002, message: Instances information unavailable: getaddrinfo: Name or service not known This can happen when pushing apps to a Diego-enabled Cloud Foundry. Components have not finished starting yet. Wait a little and try pushing again.

cf push reports an error dialing loggregator
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Loggregator has not yet registered with the router. Wait a little and this should happen.

No application health status is visible
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
The HM9000 component polls the API every 6 minutes. The first check of a new CF deployment may fail as components wire themselves together. Health status should appear within 6 minutes.

Marathon won't delete my Cloud Foundry!
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
We've seen issues where Docker refuses to kill containers, and so Marathon gets stuck with a never-ending deletion. To work around this you can sudo service docker restart on the node with the immortal container.
