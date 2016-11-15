ContainerCF
===========

Welcome to the home of Container.CF!

We are a containerized CloudFoundry build, designed to bring the container and cloudfoundry ecosystems closer together.

For background information and our reasons behind the project, please see this blog post:
http://blogs.cisco.com/cloud/containerized-cloud-foundry-is-key-element-for-cloud-native

For a quick demo on Marathon, see the video below.

Project Info and Run ContainerCF
********************************

.. toctree::
   :maxdepth: 3

   getting_started/index.rst
   known_issues.rst
   faq.rst
   license.rst

Develop ContainerCF and Pipeline
********************************
.. toctree::
   :maxdepth: 3


   development/index.rst
   development/dev-env.rst



* `Changelog <https://github.com/CiscoCloud/containercf/blob/master/CHANGELOG.md>`_

.. only:: html

Demo Video (Marathon)
*********************

.. raw:: html

   <div style="position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; max-width: 100%; height: auto;">
       <iframe src="https://www.youtube.com/embed/X5Dv3SFBWrg" frameborder="0" allowfullscreen style="position: absolute; top: 0; left: 0; width: 100%; height: 100%;"></iframe>
   </div>


Repository Layout
*****************
Consume:
-------

```run``` - Scripts and Manifests to deploy current ContainerCF images.

Develop:
--------

```concourse``` - Concourse CI pipeline Configuration and Parameters.

```components``` - Artifacts consumed by concourse for each CF component.

```environments``` - Configuration for mesos clusters used during pipeline and testing.

```scripts``` - Used by pipeline/concourse to push newly generated images to environments.

```cats``` - Configuration and scripts for running the CF CATS test against environments.

```bosh_concourse_deployment0.yml``` - Our BOSH manifest for the concourse environment (AWS).


Credits
*******
A Huge amount of credit goes to Gareth and Claudia (Github: @spikymonky and @callisto13) for their time, effort and awesomeness on this project and Colin Humphreys (@hatofmonkeys) for his guidance.
You'll find all these lovely people working over at Pivotal LDN nowadays.

The work also stood heavily the shoulders of Tommy Hughes' work on 'Running a PaaS in Docker' (https://www.ctl.io/developers/blog/post/running-a-paas-in-docker/).
This single-container CF in Docker implementation, provided our starting point and validated the base for what we wanted to acheive.

Finally, special hanks to Cisco for sponsoring the initial PoC and Development of ContainerCF.

Search
******

* :ref:`genindex`
* :ref:`search`


License
-------
Licensed under the `Apache License, Version 2.0`_ (the "License").

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

.. _Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0
