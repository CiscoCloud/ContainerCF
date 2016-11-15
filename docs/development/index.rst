Development
===========
Here we cover the development side of the project. You'll find info on the build process and repo structure below.

Initial Development Goals
-------------------------
We tried to design to the following goals, these inform a lot of the decisions made, why theres more scripting than 'extra helper applications' and why the pipeline is designed the way it is.

A version of CloudFoundry which is completley containerized, and that follows the design rules below:

1. Do not make a 'once in time' PoC. The build pipeline should be able to consume newer CloudFoundry versions.
2. Produce Generic Images. All 'administrator' configuration should be done at runtime, users shouldn't have to generate their own ContainerCF images.
3. Use the existing CloudFoundry community output (cf-release, etc) for pipeline input, we don't want to be maintaining a fork of CF components.
4. Opinionated decisions on which configuration options (see 2.) to surface in the initial release. (Ie, we've made some decisions on backend settings for you to keep runtime configuration simple).

Pipeline Overview
-----------------
The build pipeline is the "meat" of this project. Creating hacked docker images one time that created a cloudfoundry cluster would have been much easier. We wanted to create something which could be re-used and improved with newer versions of CF (See rule 1).
In keeping with the CF community, http://concourse.ci has been used to build the CI pipeline, with all scripts, data etc being stored in this repository (http://github.com/ciscocloud/containercf).

You can see the repository layout below, everything is pipeline-related apart from the ```run``` directory, which contains pre-written manifests and scripts to deploy the publicly hosted pipeline output (the containers) to marathon or kubernetes container infrastructure.

The great thing about concourse pipelines is theres only one file to read to get an overview of the flow. See ```./concourse/pipeline.yml```.
Our pipeline works in the following way:

    1. Create a base Container Image with relevant pre-requisites for all containerized components.
    2. Use this base image to build up specific container images for each 'CF component' listed in the ```./components``` directory.
    3. Configure the CF components from a static CF deployment manifest (```./components/cf-manifest/manifests/deploy.yml```)
       Using named placeholders for information we don't know (as the images are generic and not tied to a specific deployment).
    4. Inject runtime scripts which replace the IP address of this 'host' (container) at runtime wherever needed.
       (For example, all the 'Bind' / 'Listen' configuration file lines usually statically configured by BOSH when a VM is built)
       Example ```./components/api/scripts/run.sh```.
    5. Add ConfD templates which replace the 'named placeholders' from 3. at runtime with values from the Consul keystore.
       (For example, line 136 of the current ```deploy.yml``` CF manifest would normally need the DNS domain for the CF deployment.
       Instead, we have ```placeholder-f622194a.example.com```, which will be replaced by the KV store key ```/cf/system_domain``` for each deployment by ConfD.
       Monit is still used to control the components within the containers (indeed, the exact same monit configurations and binaries and /var/vcap folder structure pulled from cf-release).
    6. Push the newly generated containers to a DockerHub style docker registry (we use bintray, so the pipeline is configured for this. Others will work).
    7. Use the newly generated images to deploy to a 'dev' marathon cluster sitting side by side the pipeline workers.
    8. Run CATS against the ContainerCF deployment now running in the 'dev' marathon cluster.
    9. If successful, re-deploy to a 'stable' marathon cluster (and optionally push the images to a different docker registry/tag).

If you have read the "getting started" section for running the existing images our pipeline has produced, you'll be farmiliar with the necessary settings in ```./run/marathon/cf_parameters```.
Hopefully you can now see why these are the parameters surfaced to the user for runtime configuration and customization; Answer: They are the ones we've templated out in the CF manifest and written ConfD templates for in points 3 and 5 above.

We chose these parameters as the "minimum needed customization" for both security and operational use (such as setting your own DNS domains). It should be fairly simple to see how you'd surface another setting if you wished too.

A note on 'unsurfaced' Keys
~~~~~~~~~~~~~~~~~~~~~~~~~~~
Like many bosh manifests, there are placeholder keys (such as the internal JWT key and component to component passwords) which we've hardcoded in the ```deploy.yml``` manifest and not surfaced to run-time configuration via the process above.
Theres no reason NOT to surface these, we just haven't in this release.
If you build your own pipeline to customize the images, you could also just change them directly in the ```deploy.yml``` file, but we were going for public, re-usable generic images. (so surfacing them would be better ;) ).

Repository Layout
-----------------
Consume:
~~~~~~~~

```run``` - Scripts and Manifests to deploy current ContainerCF images.

Develop:
~~~~~~~~

```concourse``` - Concourse CI pipeline Configuration and Parameters.

```components``` - Artifacts consumed by concourse for each CF component.

```environments``` - Configuration for mesos clusters used during pipeline and testing.

```scripts``` - Used by pipeline/concourse to push newly generated images to environments.

```cats``` - Configuration and scripts for running the CF CATS test against environments.

```bosh_concourse_deployment0.yml``` - Our BOSH manifest for the concourse environment (AWS).


Setting up your own pipeline
----------------------------
To setup your own pipeline (brief overview):

1. Fork this ContainerCF repo.
2. Change the ```./concourse/pipeline.yml``` git resources (bottom of file) from ```ciscocloud/containercf``` to your own repo.
3. In the same file, change the docker image store resources (bottom of file) from ```shippedrepos-docker-sitd``` to your own docker hub or bintray account.
4. Provide your credentials for relevant resources into ```./concourse/credentials.yml```.
5. Set the parameters in ```./environments/dev/cf_parameters``` to match your own Mesos/Marathon cluster (reachable from your Concourse deployment).
6. Make sure the username/password/dns domain you've set for your dev deployment in ```cf_parameters``` is reflected in ```./cats/dev/integration_config.json``` otherwise you'r CATS tests wont be able to find your newly deployed ContainerCF or log in.
7. Commit all these changes to your new fork (as Concourse reads everything from git.)
   If you need to make the fork private due to keys, Mesos environment data etc, this is supported, see the private_key commented sections in ```pipeline.yml``` and the commented out SSH key section in ```credentials.yml```
8. Deploy the pipeline (```pipeline.yml```) to your Concourse, godspeed!

Public Images and CF versions
-----------------------------
The public images currently referenced in the ```./run``` section are the output of our initial development pipeline. They have some embedded keys for internal components.
See "A note on unsurfaced keys" above. They work, great for testing, but if you're interested in consuming ContainerCF seriously or developing on it, you'll want your own pipeline.

Our images currently produce a CloudFoundry at version 224.
(This is controlled through which cf-release the pipeline checks out in ```./components/cf-release/Dockerfile```)
If you produce newer generic images through this process, by all means shout via twitter @mattdashj or @containercf if you'd like them publicly hosting to use with our ```./run``` scripts.

An IMPORTANT note on CF upstream changes
----------------------------------------
As mentioned in the original FAQ, we're an extremely small team with day jobs.
Keen followers of the CF community will have noticed the recent 'sub-componentization' of larger cf-release sections or components into other repositories and the breakup of applications into smaller pieces within CF's core.
While the pipeline could be configured (pretty simply) to support this new structure, we currently dont have the cycles to do this; so at a certain CF version, the pipeline will break as it won't be fetching all needed components from cf-release (and/or, there will be new components that the version of CF depends on which we wont have built a container for).

The idea of this being open sourced is our work can be consumed/improved without waiting on us if you have the urge/need to move past this change sooner.

Feedback
--------
By all means shout with thoughts / suggestions / info to @containercf or @mattdashj
We're really hoping this is useful to the community, if even as a base or lessons learnt for other projects!

Keep on hacking!
