# .bash_profile
# Prepare our devops environment with variables, useful functions, and aliases.

if [ -n "${HOME}" -a -d ${HOME}/bin ] ; then
  export PATH=${PATH}:${HOME}/bin
fi

devops="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
alias ch="cd ${devops}"
alias ll="ls -lah"

git config --global alias.dammit 'submodule update --init --recursive'

for swx_step in ${devops}/swx.d/* ; do
  . "${swx_step}"
done
unset swx_step

# Set the bash prompt to show our $AWS_PROFILE
export PS1='[$AWS_PROFILE:$SWX_ENVIRONMENT:$DOCKER_MACHINE_NAME] \h:\W\$ '

change_directory .
