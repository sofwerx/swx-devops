#!/bin/bash -e
devops="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
if [ -n "${DOCKER_SH}" ]; then
  echo "*** Running in a Docker container ***"
  if ! id ${USER} > /dev/null 2>&1 ; then
    groupadd -g ${GID} ${GROUP} > /dev/null 2>&1 || true
    useradd -u ${UID} -g ${GID} -d ${devops} -s /bin/bash ${USER}
  fi
  chown ${UID}:${GID} $(tty)
  exec su ${USER} --login -c "exec bash --rcfile ${devops}/.bashrc -i $@"
fi
echo "*** Type swx followed by the tab key for swx-devops commands ***"
exec bash --rcfile "${devops}/.bashrc" -i $@
