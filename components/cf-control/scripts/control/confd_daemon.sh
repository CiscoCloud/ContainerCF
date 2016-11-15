#! /usr/bin/env bash
set -eu

pidfile="/var/run/confd.pid"
command="/root/bin/confd -backend=${CONFD_BACKEND} -node=${CONFD_NODE} -watch=true"

# Proxy signals
function kill_app(){
  kill $(cat $pidfile)
  exit 0 # exit okay
}
trap "kill_app" SIGINT SIGTERM

# Launch daemon
$command &>/var/log/confd.log & 2>&1
echo $(pidof confd) > ${pidfile}
sleep 2

# Loop while the pidfile and the process exist
while [ -f $pidfile ] && kill -0 $(cat $pidfile) ; do
  sleep 0.5
done

exit 1000 # exit unexpected
