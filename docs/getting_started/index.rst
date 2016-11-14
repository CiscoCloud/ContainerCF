Getting Started (Info)
======================

The idea behind ContainerCF is for each component of cloudfoundry to be built into docker container's instead of BOSH releases deployed virtual machines.

This removes the need to pre-specify a BOSH manifest and IP addresses/pools (which are very IaaS-centric).
Instead, ContainerCF takes a different approach to configuration, each component registers itself with a state store (in our case, Consul), this provides two important benefits;

* 1. Components of the system can find eachother.
    For example, each component can find the IP of NATS by simply looking up ```/cf/jobs/nats/containerip``` in the state store.

* 2. Initial 'bootstrap' configuration.
    Per-deployment configuration, such as default admin username and password (or the CF system DNS name etc) can all be pre-populated into the state store to dynamically configure a ContainerCF cluster on startup.
    This allows us to provide pre-built docker images for each CF component, which configure themselves for your specific environment on startup.

Therefore, ALL deployment types below need a Consul cluster to talk to, and (obviously) need to know where that consul cluster is.
The examples below start up a single node consul cluster for testing as part of the deployment scripts.

Once running, each containerized component also watches relevant parts of the configuration keystore for changes; so if the cloudcontroller API moves for any reason, dependant components will reconfigure with the new reachability details of the API component. We're using ConfD with Consul as a backing store to acheive this.

For health management, we expose the state of Monit up to the container ochestrator in use; therefore if a monit job (internal CF process/subprocess) is failing or unavailable, the container orchestrator will mark the container as unhealthy and destroy it, bringing up a new instance in it's place (which once again will be configured for reachability to other components via consul.)

One other important note, ContainerCF has not been designed to track TCP/UDP usage for each CloudFoundry component, therefore we require a container infrastructure that gives each container it's own IP address within the cluster.
Most Container infrastructure tools now do this by default, using overlays or container networking tools such as Calico, Weave, Flannel, etc. However, please bare this in mind when considering multi-host container infrastructures.

This info section was designed to provide an overview of how ContainerCF is designed to work. For more information on how this is all put together, or to dig into the build process yourself, see the development / build pipeline section of the docs.

Getting Started (Deploy)
========================

In the 'run' directory, you'll find pre-created scripts and .json manifests for Marathon and Kubernetes deployments.
As Marathon is our build/test environment, these are the most tested/validated at this time.

These scripts consume the public pre-built images for each containerized CF component.
For more information on the build process see the build/modify section of the docs.

Each deployment type is based around a single ```cf_parameters``` file, where we expect you to provide the bootstrap information needed for your new ContainerCF deployment, along with any information the container infrastructure you have chosen needs.
The deployment process follows this path:

* Fill out ```cf_parameters``` file.
* Start Consul for service discovery (scripted).
* Tell CF components where Consul is (scripted).
* Start each CF component container from the public ContainerCF docker repository (scripted).

Mesos (Marathon)
---------------
For Marathon, cf_parameters needs to know the IP of one of your slave/worker nodes and also the address of the marathon API.
These are purely so that the demo deploy scripts work, you could always use the marathon ```.json``` files directly in other ways if you wished.

cd into the ```run/marathon``` directory and you should see the following;

.. code-block:: c

    MATJOHN2-M-90LM (matjohn2) ~/coderepo/ContainerCF/run/marathon $> ll
    total 24
    drwxr-xr-x  17 matjohn2  staff   578B 14 Nov 13:59 apps/
    -rw-r--r--   1 matjohn2  staff   2.0K 14 Nov 15:32 cf_parameters
    -rw-r--r--   1 matjohn2  staff   195B 14 Nov 14:02 deploy_cf
    -rw-r--r--   1 matjohn2  staff   176B 14 Nov 14:08 deploy_service_apps
    drwxr-xr-x   3 matjohn2  staff   102B 14 Nov 14:06 services/
    -rw-r--r--   1 matjohn2  staff   3.0K 14 Nov 13:57 ssl.pem
    -rw-r--r--   1 matjohn2  staff   1.0K 14 Nov 13:58 update_cf
    -rw-r--r--   1 matjohn2  staff   399B 14 Nov 14:07 update_service_apps


Read through the comments in the ```cf_parameters``` file and update the entries to match your infrastructure.
Once done, the ```./deploy_service_apps``` command will setup a single instance consul cluster. This will be deployed to the slave/worker host you provided the IP for (so that we know where it is).

Following this, ```./deploy_cf``` will populate the new consul KV store with our CF cluster settings (basically all the keys from the ```cf_parameters``` file) then deploy each CF component (all the ```.json``` files within the ```./app``` directory.)
If you look at the deploy scripts, you'll noticed we're using JQ to combine the JSON files into one large file to post to Marathon, we're also then replacing placeholders for Consul's IP/Reachability information with the IP you provided of the marathon worker node.

Progress can then be tracked in Marathon and also componets will be seen registering in the consul keystore (theres a UI for consul on HTTP://$HOST_IP:8500) under the ```/cf/jobs``` keyspace.

Once all components are started, you should be able to target the CF API using the usual CF client binary.
During the deployment, some components may (and are designed) to die/restart in marathon as all the components come online and discover/reconfigure eachother via Consul.


Kubernetes
----------
Kubernetes has higher level traffic management primatives (such as services, DNS lookup etc) than Marathon, so the deployment scripts (and the information we need from the user in the ```cf_parameters``` file) is reduced.

cd into the ```run/kubernetes``` directory and you should see the following;

.. code-block:: c

    MATJOHN2-M-90LM (matjohn2) ~/coderepo/ContainerCF/run/kubernetes $> ll
    total 16
    drwxr-xr-x  17 matjohn2  staff   578B  8 Nov 17:47 apps/
    -rwxr-xr-x   1 matjohn2  staff   454B  8 Nov 17:59 bootstrap-ccf-k8s.sh
    -rw-r--r--   1 matjohn2  staff   1.3K 14 Nov 13:41 cf_parameters
    -rwxr-xr-x   1 matjohn2  staff   1.6K  9 Nov 15:50 deploy-ccf-k8s.sh
    drwxr-xr-x   4 matjohn2  staff   136B  8 Nov 18:14 services/
    -rw-r--r--   1 matjohn2  staff   3.0K  8 Nov 17:47 ssl.pem


Like the Marathon example, configure the relevant settings in the ```cf_parameters``` file for your deployment, then run ```./bootstrap-ccf-k8s.sh```.

You must make sure your 'kubectl' command is configured to use the cluster you want to deploy against, our demo deployment scripts just run kubectl commands.

Much like the Marathon example, this will deploy a single Consul node as our service discovery cluster, but will also assign a service (load balancer) to the consul node, so that we can discover consul's IP from other components via DNS. (ccf_consul_srv.ccf).
All the demo deployment scripts here create use the namespace ```ccf``` within kubernetes, which will be created by the ```./bootstrap-ccf-k8s.sh``` script if it does not exist.

Once done, running ```./deploy-ccf-k8s.sh``` will push the values from ```cf_parameters``` to our new consul keystore, then schedule each of the CF components as a pod within kubernetes.
For the pod descriptions of each component, see ```run/kubernetes/apps``` directory.
