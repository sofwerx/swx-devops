#!/bin/bash

# Work out of this script's folder
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

# Fail as early as possible
set -Eeuo pipefail

# Ensure the travis command is installed
which travis > /dev/null 2>&1 || bundle install

# Show who we are logged in as
travis whoami || travis login

# Sync travis with github
if travis sync --check 2>&1 | grep "not syncing" > /dev/null
then
  travis sync
else
  echo "Travis is currently syncing..."
  until travis sync --check 2>&1 | grep "not syncing" > /dev/null
  do
    echo -n .
  done
  echo ""
fi

# Converge our repositories to active
for repo in \
 sofwerx/rpi-elasticsearch \
 sofwerx/rpi-kibana \
 sofwerx/rpi-mqtt \
 sofwerx/rpi-mqtt-elasticsearch \
 sofwerx/rpi-rtl433 \
 sofwerx/rpi-tpms \
 sofwerx/synthetic-target-area-of-interest \
 ; \
do
  # Is this repo a valid travis resource?
  if travis raw /repos/${repo} > /dev/null; then
    if [ -z "$(travis repos --active --owner sofwerx --match ${repo})" ];  then
      echo travis enable -r ${repo}
    else
      echo ${repo} is active.
    fi
  else
    echo ${repo} is not a valid travis resource. Sync may not truly be complete yet.
  fi
done

# Do not run more than one rpi-tpms build at the same time
travis settings maximum_number_of_builds -r sofwerx/rpi-tpms --set 1

