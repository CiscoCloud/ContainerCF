#!/bin/bash

monit=/var/vcap/bosh/bin/monit

echo "Starting jobs..."
$monit start all

echo
echo "Waiting for remaining processes to start..."
echo
max_tries=120
for ((i=1; i <= $max_tries; i++)); do
    if ! ($monit summary | tail -n +3 | grep -v running); then
    		echo "All jobs running! Yay!"
        break
    fi
    $monit summary | grep -v -E "(running|pending|initializing)" | grep -E "(Process|System)" | cut -d\' -f2 | xargs -I {} $monit start {}
    sleep 5
    echo
    if [ $i = $max_tries ]; then
    	echo "Monit has failed to start all jobs! :("
    	break
    else
    	echo "Waiting for remaining processes to start..."
    fi
    echo
done
