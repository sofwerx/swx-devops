# .bash_profile
# Prepare our devops environment with variables, useful functions, and aliases.

if [ -n "${HOME}" -a -d ${HOME}/bin ] ; then
  export PATH=${PATH}:${HOME}/bin
fi

devops="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
alias ch="cd ${devops}"

if [ -d "${devops}/secrets/aws" ] ; then
  export AWS_SHARED_CREDENTIALS_FILE="${devops}/secrets/aws/credentials"
  export AWS_CONFIG_FILE="${devops}/secrets/aws/config"
fi
export AWS_SHARED_CREDENTIALS_FILE="${AWS_SHARED_CREDENTIALS_FILE:-~/.aws/credentials}"
export AWS_CONFIG_FILE="${AWS_CONFIG_FILE:-~/.aws/config}"
export AWS_PROFILE="${AWS_PROFILE:-sofwerx}"
if grep $AWS_PROFILE $AWS_CONFIG_FILE > /dev/null 2>&1 ; then
  export AWS_ACCESS_KEY_ID="$(aws configure get aws_access_key_id --profile $AWS_PROFILE)"
  export AWS_SECRET_ACCESS_KEY="$(aws configure get aws_secret_access_key --profile $AWS_PROFILE)"
  export AWS_REGION="${AWS_REGION:-$(aws configure get region --profile $AWS_PROFILE)}"
  export AWS_DEFAULT_REGION="${AWS_REGION}"
  export AWS_DEFAULT_OUTPUT="$(aws configure get output --profile $AWS_PROFILE)"
  export AWS_DEFAULT_OUTPUT=${AWS_DEFAULT_OUTPUT:-json}
fi

if [ -n "$DOCKER_API_VERSION" ]; then
 unset DOCKER_API_VERSION
fi

# Set the bash prompt to show our $AWS_PROFILE
export PS1='[$AWS_PROFILE:$SWX_ENVIRONMENT:$DOCKER_MACHINE_NAME] \h:\W \u\$ '

# These variables become available for terraform to use
export TF_VAR_aws_region=${AWS_REGION}
export TF_VAR_aws_access_key_id=${AWS_ACCESS_KEY_ID}
export TF_VAR_aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}

swx_gpg_prepare ()
{
  if [ -d "${devops}/secrets/gnupg" ] ; then
    export GNUPGHOME="${devops}/secrets/gnupg"
  else
    if [ -d "$HOME/.gnupg" ]; then
      export GNUPGHOME="$HOME/.gnupg"
    fi
  fi
  chmod go-rwx "$GNUPGHOME"

  if [ ! -d "$GNUPGHOME" ] ; then
    echo 'You may need to first generate a gpg key:'
    echo '    gpg --gen-key'
  fi

  if [ -d /usr/local/opt/gpg-agent ]; then
    export PATH="/usr/local/opt/gpg-agent/bin:$PATH"
    export PATH="/usr/local/opt/gpg-agent/libexec:$PATH"
  fi

  if [ -f /usr/lib/gnupg2/gpg-preset-passphrase ]; then
    export PATH=/usr/lib/gnupg2:$PATH
  fi

  if [ -f "$GNUPGHOME/.gpg-agent-info" ]; then
    . "$GNUPGHOME/.gpg-agent-info"
    export GPG_AGENT_INFO SSH_AUTH_SOCK SSH_AGENT_PID
  fi

  # If the GPG_AGENT_INFO points to a unix domain socket that doesn't exist, unset it
  if [ -n "$GPG_AGENT_INFO" -a ! -e "$(echo $GPG_AGENT_INFO | cut -d: -f1)" ]; then
    if [ -f "$GNUPGHOME/.gpg-agent-info" ]; then
      rm -f "$GNUPGHOME/.gpg-agent-info"
    fi
    unset GPG_AGENT_INFO gpg_agent_info
  fi

  # Use pinentry-mac if it is available
  if ! grep pinentry-program "$GNUPGHOME/gpg-agent.conf" > /dev/null ; then
    if which pinentry-mac > /dev/null ; then
      echo "pinentry-program /usr/local/bin/pinentry-mac" >> "$GNUPGHOME/gpg-agent.conf"
    fi
    if [ -f /usr/bin/pinentry-curses ]; then
      echo "pinentry-program /usr/bin/pinentry-curses" >> "$GNUPGHOME/gpg-agent.conf"
    fi
  fi

  if [ -z "${GPG_AGENT_INFO}" ]; then
    if which gpg-agent > /dev/null ; then
      GPG_TTY=$(tty)
      export GPG_TTY
  
      eval $(gpg-agent --daemon --enable-ssh-support --write-env-file "$GNUPGHOME/.gpg-agent-info" --allow-preset-passphrase)
    fi
  fi

  if [ -n "${GPG_AGENT_INFO}" ]; then
    export gpg_agent_info="${GPG_AGENT_INFO}"
  fi

  #if gpg-agent --use-standard-socket-p ; then
  #  echo "WARNING: Your gpg build/version/configuration is not compatible with trousseau: $(gpg --version | head -1)"
  #  echo "If gpg is running with --use-standard-socket, GPG_AGENT_INFO will not be set, which trousseau needs to operate correctly"
  #fi

  if [ -z "$KEYGRIP" ]; then
    if [ -z "$TROUSSEAU_MASTER_GPG_ID" ]; then
      TROUSSEAU_MASTER_GPG_ID=$(gpg --list-secret-keys | grep uid  | cut -d'<' -f2- | cut -d'>' -f1 | head -1)
    fi
    KEYGRIP=$(gpg --fingerprint --fingerprint | grep fingerprint | head -2 | tail -1 | cut -d= -f2 | sed -e 's/ //g')
  fi

}

swx_gpg_prepare

# This fixes my ssh-add hang problem when using gpg-agent instead of sshagent
if echo "$SSH_AUTH_SOCK" | grep gpg > /dev/null ; then
  unalias ssh-add 2>/dev/null 
  alias ssh-add="echo UPDATESTARTUPTTY | gpg-connect-agent ; ssh-add"
fi

# The trousseau and terraform commands need buckets
export TROUSSEAU_STORE="${TROUSSEAU_STORE:-${devops}/.trousseau}"

# TROUSSEAU_PRIVATE_KEY
if [ -z "${TROUSSEAU_PASSPHRASE}" ] &&
   [ -z "${TROUSSEAU_KEYRING_SERVICE}" ] &&
   [ -z "${GPG_AGENT_INFO}" ] ; then
  echo 'To save yourself some passphrase prompting pain, you may want to:'
  echo '    export TROUSSEAU_PASSPHRASE={your pgp passphrase}'
  echo 'Alternatively, you may want to add a password to your keyring service for trousseau to use:'
  echo '    export TROUSSEAU_KEYRING_SERVICE=trouseau'
fi

if [ -n "${GPG_AGENT_INFO}" -a -z "$TROUSSEAU_KEYRING_SERVICE" ]; then
  export TROUSSEAU_KEYRING_SERVICE=trouseau
fi

if which trousseau 2>&1 > /dev/null ; then
  alias trousseau="$(which trousseau) --gnupg-home $GNUPGHOME --store $TROUSSEAU_STORE"
else
  alias trousseau="echo Cannot find the trousseau command in your path"
fi

# Allow a secrets based local store of docker-machines... for Ian. You _probably_ don't want this directory.
if [ -d "${devops}/secrets/docker/machines" ]; then
  export MACHINE_STORAGE_PATH="${devops}/secrets/docker"
else
  if [ -d ~/.docker/machine/machines ] ; then
    export MACHINE_STORAGE_PATH=~/.docker/machine/machines
  fi
fi

# Install dmport if it has not been yet
if which npm > /dev/null; then
  if [ ! -d "${devops}/node_modules/" ]; then
    npm install
  fi
  export PATH=$PATH:"${devops}/node_modules/.bin"
fi

# The swx command functions are defined below.

swx_gpg ()
{
  case $1 in
prepare) shift; swx_gpg_prepare $@ ;;
remember) shift; swx_gpg_remember $@ ;;
forget) shift; swx_gpg_forget $@ ;;
reset) shift; swx_gpg_reset $@ ;;
*) cat <<EOU 1>&2
Usage: swx gpg {action}
  prepare  - Prepare your gpg-agent environment
  remember - Remember your passphrase (gpg-agent)
  forget   - Forget your passphrase (gpg-agent)
  reset    - Reset your gpg-agent
EOU
  return 1
  ;;
  esac
}


swx_gpg_reset ()
{
  kill $(echo $GPG_AGENT_INFO | cut -d: -f2)
  unset GPG_AGENT_INFO gpg_agent_info
  if [ -f $GNUPGHOME/.gpg-agent-info ]; then
    rm -f $GNUPGHOME/.gpg-agent-info
  fi
}

swx_gpg_remember ()
{
  swx_gpg_prepare
  echo -n 'Please enter your gpg key passphrase: '
  stty -echo
  gpg-preset-passphrase --preset $KEYGRIP
  stty echo
  echo ''
}

swx_gpg_forget ()
{
  swx_gpg_prepare
  gpg-preset-passphrase --forget $KEYGRIP
}

swx_tf ()
{
  if [ "$(basename $PWD)" = "terraform" ]; then
    environment="$(basename $(echo $PWD | sed -e 's/\/terraform$//' ))"
    swx_environment_switch $environment
    if [ -f tf.sh ]; then
      . tf.sh
    fi
    terraform $@
  else
    echo "This isn't a directory named 'terraform', please cd there and re-run this command" 1>&2
    return 1
  fi
}

swx_dm_ls ()
{
  trousseau keys | grep -e ^file:secrets/dm/ | cut -d/ -f3-
}

swx_dm_env ()
{
  if which dmport > /dev/null ; then
    mkdir -p "${devops}/secrets/dm"
    if trousseau get file:secrets/dm/$1 > /dev/null 2>&1 ; then
      swx_secrets_decrypt secrets/dm/$1
      if  [ -s "${devops}/secrets/dm/$1" ]; then
        dm="$(cat ${devops}/secrets/dm/$1)"
        eval $(dmport --import $dm)
        if trousseau get dm2environment:$1 > /dev/null 2>&1 ; then
          environment="$(trousseau get dm2environment:$1)"
          swx_environment_switch $environment
        fi
      fi
    else
      if [ -s "${devops}/secrets/dm/$1" ]; then
        echo "dm $1 does not exist in trousseau, but does exist as a secrets file in ${devops}/secrets/dm/$1"
        echo "you may want to run this: swx secrets encrypt secrets/dm/$1"
      else
        echo "dm $1 does not exist. try: swx dm ls"
      fi
      return 1
    fi
  else
    echo "You need to do a npm install of dmport to use this function."
    return 1
  fi
}

swx_dm_import ()
{
  if which dmport > /dev/null ; then
    dmport --export $1 > "${devops}/secrets/dm/$1"
    swx_secrets_encrypt secrets/dm/$1
  else
    echo "You need to do a npm install of dmport to use this function." 1>&2
    return 1
  fi
}

swx_dm ()
{
  case $1 in
ls) shift; swx_dm_ls $@ ;;
env) shift; swx_dm_env $@ ;;
import) shift; swx_dm_import $@ ;;
*) cat <<EOU 1>&2
Usage: swx dm {action}
  ls     - List dm instances
  env    - Source the environment to interact with a dm instance using docker
  import - Import a docker-machine instance into a dm
EOU
  return 1
  ;;
  esac
}

swx_environment_ls ()
{
  trousseau keys | grep -e ^environment: | cut -d: -f2 | sort | uniq
}

swx_environment_switch ()
{
  environment=$1

  if trousseau keys | grep -e "^environment:${environment}:" > /dev/null ; then

    # Undefine any variables from an already sourced environment
    if [ -n $SWX_ENVIRONMENT ]; then
      for variable in $(trousseau keys | grep -e "^environment:${SWX_ENVIRONMENT}:" | sed -e "s/^environment:${SWX_ENVIRONMENT}://"); do
        unset "$variable"
      done
    fi

    # Define variables from the newly selected environment
    export SWX_ENVIRONMENT=$environment
    for variable in $(trousseau keys | grep -e "^environment:${SWX_ENVIRONMENT}:" | sed -e "s/^environment:${SWX_ENVIRONMENT}://"); do
      export ${variable}="$(trousseau get environment:${SWX_ENVIRONMENT}:${variable})"
    done
  else
    echo "No environment variables exist in trousseau for environment: $environment" 1>&2
    return 1
  fi
}

swx_environment ()
{
  case $1 in
ls) shift; swx_environment_ls ;;
switch) shift; swx_environment_switch $@ ;;
*) cat <<EOU 1>&2
Usage: swx dm environment {action}
  ls     - List environments
  switch - Switch to an environment
EOU
  return 1
  ;;
  esac
}

swx_secrets_addrecipients ()
{
  ls -1 "$(devops)/gpg" | while read recipient; do trousseau add-recipient $recipient; done
}

swx_secrets_decrypt ()
{
  secret="$@"
  trousseau get "file:$secret" | openssl enc -base64 -d -A > "${devops}/$secret"
}

swx_secrets_encrypt ()
{
  secret="$@"
  trousseau set "file:$1" "$(openssl enc -base64 -A -in ${devops}/$1)"
}

swx_secrets_pull ()
{
  trousseau keys | grep -e ^file:secrets/ | sed -e s/^file:// | while read file; do swx_secrets_decrypt "$file"; done
}

swx_secrets ()
{
  case $1 in
addrecipients) shift; swx_secrets_addrecipients $@ ;;
decrypt) shift; swx_secrets_decrypt $@ ;;
encrypt) shift; swx_secrets_encrypt $@ ;;
pull) shift; swx_secrets_pull ;;
*) cat <<EOU 1>&2
Usage: swx secrets {action}
  addrecipients - trousseau add recipients from the gpg/ folder
  decrypt - decrypt a secrets/ file from trousseau
  encrypt - encrypt a secrets/ file into trousseau
  pull    - pull files stored in trousseau into secrets/ folder
EOU
  return 1
  ;;
  esac
}

_swx ()
{
  local cur
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  case "${COMP_WORDS[*]}" in
    "swx dc"*) COMPREPLY=( $( compgen -W "build bundle config create down events exec help images kill logs pause port ps pull push restart rm run scale start stop top unpause up version" -- $cur ) ) ;;
    "swx dm ls"*) COMPREPLY=( $( compgen -W "" -- $cur ) ) ;;
    "swx dm env"*) COMPREPLY=( $( compgen -W "$(swx_dm_ls)" -- $cur ) ) ;;
    "swx dm"*) COMPREPLY=( $( compgen -W "ls env import" -- $cur ) ) ;;
    "swx gpg"*) COMPREPLY=( $( compgen -W "prepare remember forget reset" -- $cur ) ) ;;
    "swx environment ls"*) COMPREPLY=( $( compgen -W "" -- $cur ) ) ;;
    "swx environment switch"*) COMPREPLY=( $( compgen -W "$(swx_environment_ls)" -- $cur ) ) ;;
    "swx environment"*) COMPREPLY=( $( compgen -W "ls switch"  -- $cur ) ) ;;
    "swx secrets addrecipients"*) COMPREPLY=( $( compgen -W "" -- $cur ) ) ;;
    "swx secrets encrypt "*) COMPREPLY=( $( compgen -W "$(find secrets/ -type f | grep -v -e 'gnupg\|docker')" -- $cur ) ) ;;
    "swx secrets decrypt "*) COMPREPLY=( $( compgen -W "$(trousseau keys | grep -e ^file:secrets/ | sed -e s/^file://)" -- $cur ) ) ;;
    "swx secrets pull "*) COMPREPLY=( $( compgen -W "" -- $cur ) ) ;;
    "swx secrets"*) COMPREPLY=( $( compgen -W "addrecipients decrypt encrypt pull" -- $cur ) ) ;;
    "swx tf"*) COMPREPLY=( $( compgen -W "apply destroy fmt get graph import init output plan push refresh remote show taint untaint validate version state" -- $cur ) ) ;;
    *) COMPREPLY=( $( compgen -W 'dc dm environment secrets tf' -- $cur ) ) ;;
  esac
  return 0
}
complete -F _swx swx

swx ()
{
  case $1 in
gpg) shift; swx_gpg $@ ;;
dm) shift; swx_dm $@ ;;
environment) shift; swx_environment $@ ;;
secrets) shift; swx_secrets $@ ;;
tf) shift; swx_tf $@ ;;
*) cat <<EOU 1>&2
Usage: swx {command}
  gpg         - Interact with your gpg-agent
  dm          - Manage dm (docker-machines)
  environment - Source project-lifecycle environment variables
  secrets     - Deal with secrets/ folder
  tf          - Run Terraform for a project-lifecycle
EOU
  return 1
  ;;
  esac
}
alias swx="swx"
complete -F _swx swx

change_directory ()
{
  unalias cd 2>/dev/null 
  \cd $@
  alias cd='change_directory $@'
  if [ -f .dm ]; then
    swx dm env $(cat .dm)
  fi
}

change_directory .

