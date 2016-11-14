Known Issues
============

Here we document some of the current known-issues, along with how we're thinking of solving them.


Direct coupling of Monit failures to container failures
-------------------------------------------------------
It was elegant and simple, in keeping with "be as close to the BOSH release pipeline as possible for future upgrades" mantra, we simply listen for any failed monit jobs in each container to work out if the container is healthy.
as each container is still running monit for the jobs within it, just like a BOSH-based VM of the same type (such as API) would be.

However, this does cause potentially more restarts of containers in certain scenarios than necessary due to re-configuration of components via confd/consul.

For example, lets say the loggretator-trafficcontroller container has crashed. A new one will take it's place, this new one will likley be assigned a different IP than it's predecessor, and so the consul key ```/cf/jobs/loggregator-trafficcontroller/containerip``` will be updated with the new IP for the container.
Dependant jobs in other ContainerCF containers will notice this change, reconfigure relevant components (via confd) and monit restart the affected jobs.

However, the container stack will then notice this monit 'restarting' status and potentially mark the container as failed. In this case, this container will be restarted, using the correct data from consul to configure itself as it comes back up.

Half of me is OK with this; (containers are meant to restart / new instance if someone wants to change something... right?)
However, the other half wonders if we should allow Monit to try a couple of times on a state change (like BOSH allows), then we surface a failure to the container orchestrator after X time/failures to schedule a replacement instance.

This would simply require a new script in the build chain of the containers, allowing for the more complex health checking, then mesos/kubernetes health checks for each component would change to use this new check logic.
Ie, this, for api.json's Kubernetes POD definition, currently checks if all monit jobs are healthy:

.. code-block:: c

    livenessProbe:
      exec:
        command: ["/bin/sh", "-c", "!(/var/vcap/bosh/bin/monit summary | tail -n +3 | grep -v -E '(running|accessible)$' )"]
      initialDelaySeconds: 20
      timeoutSeconds: 10

(Taken from ```run/kubernetes/apps/api.json```).

This would be changed to query our new script in each container, which implements more complex monit checking logic;

.. code-block:: c

    livenessProbe:
      exec:
        command: ["/bin/sh", "-c", "/var/vcap/bosh/bin/newmonitcheck.sh"]
      initialDelaySeconds: 20
      timeoutSeconds: 10

Central dependancy on NATS for each DEA
---------------------------------------
When coupled with the issue above, imagine the NATS container dies, a new one will pretty much immediatley be available, but re-configuring each DEA via confd/consul could cause each DEA to be marked as failed around the same time, obviously this is bad.
The solution is either the updates to the health check/surfacing process above, or simply placing a LB/Proxy infront of NATS.

IE, imagine the KV store key ```/cf/jobs/nats/containerip``` is set to the IP of a simple TCP proxy.
If the NATS container dies, sure the proxy will have to send NATS messages to the new container and some TCP sessions will fail in the meantime, but the IP of NATS (from the view of all DEA's and other components) never changes, allowing NATS to recover without alerting all components.
