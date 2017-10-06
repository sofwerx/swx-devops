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
fi

if [ -d $GNUPGHOME ] ; then
  KEYGRIP=$(gpg --fingerprint --fingerprint | grep fingerprint | tail -1 | cut -d= -f2 | sed -e 's/ //g')
  alias gpg_remember="echo -n 'Please enter your gpg key passphrase: '; stty -echo; gpg-preset-passphrase --preset $KEYGRIP ; stty echo ; echo ''"
  alias gpg_forget="gpg-preset-passphrase --forget $KEYGRIP"
  if [ -z "$GPG_AGENT_INFO" ]; then
    if which gpg-agent > /dev/null ; then
      GPG_TTY=$(tty)
      export GPG_TTY

      eval $(gpg-agent --daemon --enable-ssh-support --write-env-file $HOME/.gpg-agent-info --allow-preset-passphrase)
    fi
  fi
  export TROUSSEAU_MASTER_GPG_ID=$(gpg --list-secret-keys | grep uid  | cut -d'<' -f2- | cut -d'>' -f1)
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
  if [ -d $GNUPGHOME ]; then
    echo 'To save yourself some passphrase prompting pain, you may want to:'
    echo '    export TROUSSEAU_PASSPHRASE={your pgp passphrase}'
    echo 'Alternatively, you may want to add a password to your keyring service for trousseau to use:'
    echo '    export TROUSSEAU_KEYRING_SERVICE=trouseau'
  else
    echo 'You may need to first generate a gpg key:'
    echo '    gpg --gen-key'
  fi
fi

if [ -n "${GPG_AGENT_INFO}" -a -z "$TROUSSEAU_KEYRING_SERVICE" ]; then
  export TROUSSEAU_KEYRING_SERVICE=trouseau
fi

alias trousseau="$(which trousseau) --gnupg-home $GNUPGHOME --store $TROUSSEAU_STORE"

secret_decrypt ()
{
  secret="$@"
  trousseau get "file:$secret" | openssl enc -base64 -d -A > "./$secret"
}

secret_encrypt ()
{
  secret="$@"
  trousseau set "file:$1" "$(openssl enc -base64 -A -in $1)"
}

alias secrets_pull='trousseau keys | grep -e ^file:secrets/ | sed -e s/^file:// | while read file; do secret_decrypt "$file"; done'
alias recipients_add='ls -1 gpg | while read recipient; do trousseau add-recipient $recipient; done'

switch_environment ()
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

alias list_environments='trousseau keys | grep -e ^environment: | cut -d: -f2 | sort | uniq'

# Docker variables
export MACHINE_STORAGE_PATH=${devops}/secrets/docker
