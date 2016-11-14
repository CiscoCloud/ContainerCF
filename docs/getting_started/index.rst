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

For more information on how this is all put together, see the development / build pipeline section of the docs.

Getting Started (Deploy)
========================

In the 'run' directory, you'll find pre-created scripts and .json manifests for Marathon and Kubernetes deployments.
As Marathon is our build/test environment, these are the most tested/validated at this time.

These scripts consume the public pre-built images for each containerized CF component.
For more information on the build process see the build/modify section of the docs.


Mesos (Marathon)
---------------



Kubernetes
----------
