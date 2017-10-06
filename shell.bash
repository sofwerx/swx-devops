#!/bin/bash
devops="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec bash --rcfile ${devops}/.bashrc -i $@
