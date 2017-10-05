#!/bin/bash
devops=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
exec bash --rcfile ${devops}/.bashrc -i $@
