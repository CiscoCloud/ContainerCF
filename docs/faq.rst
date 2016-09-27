FAQs
====

Why did you guys create this?
------------------------------

After lots of conversations with customers, who straddle the PaaS (CloudFoundry)
and Container (Docker/rkt/mesos/k8's) ecosystems, we found more and more reasons to
try and bring the ecosystems closer together. Orchestration seemed the primary hurdle.

For a full writeup of our reasoning, see `this blog post. <https://blogs.cisco.com/containerized-cf>`_?

Where is the Code?
------------------

Over the next few days, we'll be adding to the documentation as we
get everything out in the open. Firstly the consumable public docker repo
with pre-built containerCF images, followed by the pipeline code and known-issues.

We are an extremely small team with day jobs, so please bear with us. We'd rather have useful docs
ready for each piece to prevent much head-scratching.

Is this ready for production?
-----------------------------

This is the first release of an effort to containerize CF, built using a pipeline-up approach
in order to make it useable/upgradeable into the future.

It *should* be considered a preview release.

It works, recovers, converges and we can't wait to see where the community takes it;
BUT, there are some known issues we'll be documenting on the 'Known Issues' page which you should
consider and test before jumping in with any high-value workload.
