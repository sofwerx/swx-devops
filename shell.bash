#!/bin/bash
devops="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo "*** Type swx followed by the tab key for swx-devops commands ***"
exec bash --rcfile "${devops}/.bashrc" -i $@

