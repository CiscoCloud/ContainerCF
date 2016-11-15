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
UPDATE!
Everything we have is now in this repo, including docs and a writeup of the pipeline.
See the new sections of http://container.cf for details.

Is this ready for production?
-----------------------------

This is the first release of an effort to containerize CF, built using a pipeline-up approach
in order to make it useable/upgradeable into the future.

It *should* be considered a preview release.

It works, recovers, converges and we can't wait to see where the community takes it;
We've documented a couple of issues on the 'Known Issues' page which you should
consider and test before jumping in with any valued workloads.

Also, for versioning, please see the CF version note at the bottom of the development page.
