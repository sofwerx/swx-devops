#!/bin/bash
cd "$(dirname ${BASH_SOURCE[0]})"
docker build -t swx-devops .
# This only works if the docker-engine can volume mount this directory as shared
MY_GROUP="$(id -g -n)"
MY_GID="$(id -g)"
MY_UID="$(id -u)"
ROOTPATH=""

# Are we running under the Windows Subsystem for Linux (WSL)?
## https://github.com/Microsoft/WSL/issues/2578
if which powershell.exe > /dev/null 2>&1 && [ -d /mnt/[a-z] ]; then
  RUN_ID="/tmp/$(date +%s)"

  # Mark our filesystem with a temporary file having an unique name.
  touch "${RUN_ID}"

  powershell.exe -Command '(Get-ChildItem HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss | ForEach-Object {Get-ItemProperty $_.PSPath}).BasePath.replace(":", "").replace("\", "/")' | while IFS= read -r BASEPATH; do
    # Remove trailing whitespaces.
    BASEPATH="${BASEPATH%"${BASEPATH##*[![:space:]]}"}"
    # Build the path on WSL.
    BASEPATH="/mnt/${BASEPATH,}/rootfs/"

    # Current WSL instance doesn't have an access to its mount from within
    # itself despite all others are available. That's the hacky way we're
    # using to determine current instance.
    #
    # The second of part of the condition is a fallback for a case if our
    # trick will stop working. For that we've created a temporary file with
    # an unique name and now seeking it among all WLSs.
    if ! ls "${BASEPATH}" > /dev/null 2>&1 || [ -f "${BASEPATH}${RUN_ID}" ]; then
      ROOTPATH="$(echo ${BASEPATH} | sed -e 's%/mnt/[a-z]%\\1:%')"
    fi
  done

  rm "${RUN_ID}"
fi

docker run -ti --rm --hostname swx-devops --volume "${ROOTPATH}${PWD}/:/swx" --volume "${ROOTPATH}${HOME}/:/root" -e "HOME=/root" -e "LOGNAME=${LOGNAME}" -e "USER=${USER}" -e "UID=${MY_UID}" -e "GROUP=${MY_GROUP}" -e "GID=${MY_GID}" -e "DOCKER_SH=1" swx-devops
