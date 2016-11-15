#!/bin/bash
drain_command="/var/vcap/jobs/dea_next/templates/deterministic_drain.rb"

until [ $($drain_command) == "0" ]
do
  echo "Waiting for DEA to drain. Sleeping for 5 seconds..."
  sleep 5
done

echo "DEA has drained."

