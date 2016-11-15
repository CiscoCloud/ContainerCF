#!/bin/sh

echo "Waiting to acquire DEA drain lock..."

/root/bin/consul lock -http-addr CONFD_NODE_PLACEHOLDER /cf/jobs/dea/drain /root/drain_dea.sh

