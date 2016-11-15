#!/bin/sh

CONTAINER_IP=$(ip addr | grep 'inet .*global' | cut -f 6 -d ' ' | cut -f1 -d '/' | head -n 1)

curl -X PUT -d ${HOST} http://${CONFD_NODE}/v1/kv/cf/jobs/${CF_JOB}/host_ip
curl -X PUT -d ${CONTAINER_IP} http://${CONFD_NODE}/v1/kv/cf/jobs/${CF_JOB}/container_ip
