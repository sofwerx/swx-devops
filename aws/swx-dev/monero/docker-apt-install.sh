#!/bin/bash
#
# helper to correctly do an 'apt-get install' inside a Dockerfile's RUN
#
# the upstream mirror seems to fail a lot so this will retry 5 times
#
# todo: this is copypasta with bwstitt/library-ubuntu/src/
#

set -eo pipefail

function apt-install {
    apt-get install --no-install-recommends -y "$@"
}

function retry {
    # inspired by:
    # http://unix.stackexchange.com/questions/82598/how-do-i-write-a-retry-logic-in-script-to-keep-retrying-to-run-it-upto-5-times
    local n=1
    local max=5
    local delay=5
    while true; do
        echo "Attempt ${n}/${max}: $@"
        "$@"
        local exit_code=$?

        if [ "$exit_code" -eq 0 ]; then
            echo "Attempt ${n}/${max} was successful"
            break
        elif [[ $n -lt $max ]]; then
            echo "Attempt ${n}/${max} exited non-zero ($exit_code)"
            ((n++))
            echo "Sleeping $delay seconds..."
            sleep $delay;
        else
            echo "Attempt ${n}/${max} exited non-zero ($exit_code). Giving up"
            return $exit_code
        fi
    done
}

export DEBIAN_FRONTEND=noninteractive

echo "apt-key update:"
apt-key update 2>&1

echo
echo "apt-get update:"
apt-get update

echo
echo "Downloading packages..."
retry apt-install --download-only "$@" || true

echo
echo "Installing packages..."
apt-install "$@"

echo
echo "Cleaning up..."
rm -rf /var/lib/apt/lists/*

# docker's official debian and ubuntu images do apt-get clean for us
