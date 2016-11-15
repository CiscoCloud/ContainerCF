#!/bin/bash

# Fixes goo.gl/TRvY2d
rsyslogd

/root/job/register_with_service_discovery.sh
/root/job/template_all_the_things.pl
/root/job/start_monit_jobs.sh
