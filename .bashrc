# .bash_profile
# Prepare our devops environment with variables, useful functions, and aliases.

devops="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
alias ch="cd ${devops}"

export AWS_CONFIG_FILE=${AWS_CONFIG_FILE:-~/.aws/config}
export AWS_PROFILE=${AWS_PROFILE:-sofwerx}
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id --profile $AWS_PROFILE)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key --profile $AWS_PROFILE)
export AWS_REGION=${AWS_REGION:-$(aws configure get region --profile $AWS_PROFILE)}
export AWS_DEFAULT_REGION=${AWS_REGION}
export AWS_DEFAULT_OUTPUT=$(aws configure get output --profile $AWS_PROFILE)

# Set the bash prompt to show our $AWS_PROFILE
export PS1='[$AWS_PROFILE:$SWX_ENVIRONMENT] \h:\W \u\$ '

# These variables become available for terraform to use
export TF_VAR_aws_region=${AWS_REGION}
export TF_VAR_aws_access_key_id=${AWS_ACCESS_KEY_ID}
export TF_VAR_aws_secret_access_key=${AWS_SECRET_ACCESS_KEY}

if [ -d ${devops}/secrets/gnupg ] ; then
  export GNUPGHOME=${devops}/secrets/gnupg
else
  if [ -d "$HOME/.gnupg" ]; then
    export GNUPGHOME="$HOME/.gnupg"
  fi
fi

if [ -d /usr/local/opt/gpg-agent ]; then
  export PATH="/usr/local/opt/gpg-agent/bin:$PATH"
  export PATH="/usr/local/opt/gpg-agent/libexec:$PATH"
fi

if [ -f "$HOME/.gpg-agent-info" ]; then
  . "$HOME/.gpg-agent-info"
  export GPG_AGENT_INFO SSH_AUTH_SOCK SSH_AGENT_PID
else
  if which gpg-agent > /dev/null ; then
    GPG_TTY=$(tty)
    export GPG_TTY

    eval $(gpg-agent --daemon --enable-ssh-support --write-env-file $HOME/.gpg-agent-info --allow-preset-passphrase)
  fi
fi

if [ -d $GNUPGHOME ] ; then
  export TROUSSEAU_MASTER_GPG_ID=$(gpg --list-secret-keys | grep uid  | cut -d'<' -f2- | cut -d'>' -f1)
  KEYGRIP=$(gpg --fingerprint --fingerprint | grep fingerprint | tail -1 | cut -d= -f2 | sed -e 's/ //g')
  alias gpg_remember="echo -n 'Please enter your gpg key passphrase: '; stty -echo; gpg-preset-passphrase --preset $KEYGRIP ; stty echo ; echo ''"
  alias gpg_forget="gpg-preset-passphrase --forget $KEYGRIP"
else
  echo 'You may need to first generate a gpg key:'
  echo '    gpg --gen-key'
fi

# Use pinentry-mac if it is available
if which pinentry-mac > /dev/null ; then
  if ! grep pinentry-program $GNUPGHOME/gpg-agent.conf > /dev/null ; then
    echo "pinentry-program /usr/local/bin/pinentry-mac" >> $GNUPGHOME/gpg-agent.conf
  fi
fi

if gpg-agent --use-standard-socket-p ; then
  echo "WARNING: Your gpg build/version/configuration is not compatible with trousseau: $(gpg --version | head -1)"
  echo "If gpg is running with --use-standard-socket, GPG_AGENT_INFO will not be set, which trousseau needs to operate correctly"
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

alias trousseau="$(which trousseau) --gnupg-home $GNUPGHOME --store $TROUSSEAU_STORE"

alias recipients_add='ls -1 gpg | while read recipient; do trousseau add-recipient $recipient; done'

# Allow a secrets based local store of docker-machines... for Ian. You _probably_ don't want this directory.
if [ -d ${devops}/secrets/docker/machines ]; then
  export MACHINE_STORAGE_PATH=${devops}/secrets/docker
else
  if [ -d ~/.docker/machine/machines ] ; then
    export MACHINE_STORAGE_PATH=~/.docker/machine/machines
  fi
fi

# Install dmport if it has not been yet
if which npm > /dev/null; then
  if [ ! -d ${devops}/node_modules/ ]; then
    npm install
  fi
  export PATH=$PATH:${devops}/node_modules/.bin
fi

fn_tf ()
{
  if [ "$(basename $PWD)" = "terraform" ]; then
    environment="$(basename $(echo $PWD | sed -e 's/\/terraform$//' ))"
    fn_swx_environment_switch $environment
  else
    echo "This isn't a directory named 'terraform', please cd there and re-run this command"
  fi
  terraform $@
}
alias tf="fn_tf"

fn_swx_dm_ls ()
{
  trousseau keys | grep -e ^file:secrets/dm/ | cut -d/ -f3-
}

fn_swx_dm_env ()
{
  if which dmport > /dev/null ; then
    if trousseau get file:secrets/dm/$1 > /dev/null 2>&1 ; then
      fn_swx_secrets_decrypt secrets/dm/$1
      if  [ -s ${devops}/secrets/dm/$1 ]; then
        dm="$(cat ${devops}/secrets/dm/$1)"
        eval $(dmport --import $dm)
      fi
    else
      if [ -s ${devops}/secrets/dm/$1 ]; then
        echo "dm $1 does not exist in trousseau, but does exist as a secrets file in ${devops}/secrets/dm/$1"
        echo "you may want to run this: swx secrets encrypt secrets/dm/$1"
      else
        echo "dm $1 does not exist. try dm_ls"
      fi
    fi
  else
    echo "You need to do a npm install of dmport to use this function."
  fi
}

fn_swx_dm_import ()
{
  if which dmport > /dev/null ; then
    dmport --export $1 > ${devops}/secrets/dm/$1
    fn_swx_secrets_encrypt secrets/dm/$1
  else
    echo "You need to do a npm install of dmport to use this function."
  fi
}

fn_swx_dm ()
{
  case $1 in
ls) shift; fn_swx_dm_ls $@ ;;
env) shift; fn_swx_dm_env $@ ;;
import) shift; fn_swx_dm_import $@ ;;
*) cat <<EOU
Usage: swx dm {action}
  ls     - List dm instances
  env    - Source the environment to interact with a dm instance using docker
  import - Import a docker-machine instance into a dm
EOU
  ;;
  esac
}

fn_swx_environment_ls ()
{
  trousseau keys | grep -e ^environment: | cut -d: -f2 | sort | uniq
}

fn_swx_environment_switch ()
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
    echo "No environment variables exist in trousseau for environment: $environment"
  fi
}

fn_swx_environment ()
{
  case $1 in
ls) shift; fn_swx_environment_ls ;;
switch) shift; fn_swx_environment_switch $@ ;;
*) cat <<EOU
Usage: swx dm environment {action}
  ls     - List environments
  switch - Switch to an environment
EOU
  ;;
  esac
}

fn_swx_secrets_addrecipients ()
{
  ls -1 $(devops)/gpg | while read recipient; do trousseau add-recipient $recipient; done
}

fn_swx_secrets_decrypt ()
{
  secret="$@"
  trousseau get "file:$secret" | openssl enc -base64 -d -A > "${devops}/$secret"
}

fn_swx_secrets_encrypt ()
{
  secret="$@"
  trousseau set "file:$1" "$(openssl enc -base64 -A -in ${devops}/$1)"
}

fn_swx_secrets_pull ()
{
  trousseau keys | grep -e ^file:secrets/ | sed -e s/^file:// | while read file; do fn_swx_secrets_decrypt "$file"; done
}

fn_swx_secrets ()
{
  case $1 in
addrecipients) shift; fn_swx_secrets_addrecipients $@ ;;
decrypt) shift; fn_swx_secrets_decrypt $@ ;;
encrypt) shift; fn_swx_secrets_encrypt $@ ;;
pull) shift; fn_swx_secrets_pull ;;
*) cat <<EOU
Usage: swx secrets {action}
  addrecipients - trousseau add recipients from the gpg/ folder
  decrypt - decrypt a secrets/ file from trousseau
  encrypt - encrypt a secrets/ file into trousseau
  pull    - pull files stored in trousseau into secrets/ folder
EOU
  ;;
  esac
}

_fn_swx ()
{
  local cur
  COMPREPLY=()
  cur=${COMP_WORDS[COMP_CWORD]}
  case "${COMP_WORDS[*]}" in
    "swx dm") COMPREPLY=( $( compgen -W "ls env import" -- $cur ) ) ;;
    "swx dm ") COMPREPLY=( $( compgen -W "ls env import" -- $cur ) ) ;;
    "swx dm ls"*) COMPREPLY=( $( compgen -W "" -- $cur ) ) ;;
    "swx dm env"*) COMPREPLY=( $( compgen -W "$(fn_swx_dm_ls)" -- $cur ) ) ;;
    "swx environment") COMPREPLY=( $( compgen -W "ls switch"  -- $cur ) ) ;;
    "swx environment ") COMPREPLY=( $( compgen -W "ls switch"  -- $cur ) ) ;;
    "swx environment ls"*) COMPREPLY=( $( compgen -W "" -- $cur ) ) ;;
    "swx environment switch"*) COMPREPLY=( $( compgen -W "$(fn_swx_environment_ls)" -- $cur ) ) ;;
    "swx secrets") COMPREPLY=( $( compgen -W "decrypt encrypt pull" -- $cur ) ) ;;
    "swx secrets ") COMPREPLY=( $( compgen -W "decrypt encrypt pull" -- $cur ) ) ;;
    "swx secrets addrecipients*") COMPREPLY=( $( compgen -W "" -- $cur ) ) ;;
    "swx secrets encrypt*") COMPREPLY=( $( compgen -W "" -- $cur ) ) ;;
    "swx secrets decrypt*") COMPREPLY=( $( compgen -W "" -- $cur ) ) ;;
    "swx secrets pull*") COMPREPLY=( $( compgen -W "" -- $cur ) ) ;;
    "swx secrets"*) COMPREPLY=( $( compgen -W "$(fn_swx_environment_ls)" -- $cur ) ) ;;
    "swx tf") COMPREPLY=( $( compgen -W "apply destroy fmt get graph import init output plan push refresh remote show taint untaint validate version state" -- $cur ) ) ;;
    *) COMPREPLY=( $( compgen -W 'dm env' -- $cur ) ) ;;
  esac
  return 0
}
complete -F _fn_swx fn_swx

fn_swx ()
{
  case $1 in
dm) shift; fn_swx_dm $@ ;;
environment) shift; fn_swx_environment $@ ;;
secrets) shift; fn_swx_secrets $@ ;;
tf) shift; fn_tf $@ ;;
*) cat <<EOU
Usage: swx {command}
  dm          - Manage dm (docker-machines)
  environment - Source project-lifecycle environment variables
  secrets     - Deal with secrets/ folder
  tf          - Run Terraform for a project-lifecycle
EOU
  ;;
  esac
}
alias swx="fn_swx"
complete -F _fn_swx swx

