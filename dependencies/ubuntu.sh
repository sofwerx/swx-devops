#!/bin/bash
set -e
which pip > /dev/null || (
  sudo apt-get install -y python-pip
  sudo pip install --upgrade pip
)
which aws > /dev/null || (
  sudo pip install awscli
)
which unzip > /dev/null || (
  sudo apt-get install -y unzip
)
which terraform > /dev/null || (
  cd /tmp
  wget https://releases.hashicorp.com/terraform/0.10.7/terraform_0.10.7_linux_amd64.zip
  unzip terraform_0.10.7_linux_amd64.zip
  sudo mv terraform /usr/local/bin/terraform
)
which trousseau > /dev/null || (
  cd /tmp
  wget https://github.com/oleiade/trousseau/releases/download/0.4.0/trousseau_0.4.0_amd64.deb
  sudo dpkg -i trousseau_0.4.0_amd64.deb
)
#if [ "$(gpg2 --version | head -1 | cut -d' ' -f3- | cut -d. -f1-2)" != "2.0" ]; then
which gpg2 > /dev/null || (
  sudo chmod ugo+rwx /etc/apt/preferences.d /etc/apt/sources.list.d
  grep -e ^deb /etc/apt/sources.list | sed -e 's/xenial/trusty/g' -e 's/zesty/trusty/g' -e 's/artful/trusty/g' > /etc/apt/sources.list.d/trusty.list
  cat <<EOF > /etc/apt/preferences.d/gnupg
Package: gnupg2:i386
Pin: release n=yakkety
Pin-Priority: -10

Package: gnupg-agent:i386
Pin: release n=yakkety
Pin-Priority: -10

Package: gnupg2
Pin: release n=yakkety
Pin-Priority: -10

Package: gnupg-agent
Pin: release n=yakkety
Pin-Priority: -10

Package: gnupg2:i386
Pin: release n=zesty
Pin-Priority: -10

Package: gnupg-agent:i386
Pin: release n=zesty
Pin-Priority: -10

Package: gnupg2
Pin: release n=zesty
Pin-Priority: -10

Package: gnupg-agent
Pin: release n=zesty
Pin-Priority: -10

Package: gnupg2:i386
Pin: release n=artful
Pin-Priority: -10

Package: gnupg-agent:i386
Pin: release n=artful
Pin-Priority: -10

Package: gnupg2
Pin: release n=artful
Pin-Priority: -10

Package: gnupg-agent
Pin: release n=artful
Pin-Priority: -10

Package: gnupg2:i386
Pin: release n=xenial
Pin-Priority: -10

Package: gnupg-agent:i386
Pin: release n=xenial
Pin-Priority: -10

Package: gnupg2
Pin: release n=xenial
Pin-Priority: -10

Package: gnupg-agent
Pin: release n=xenial
Pin-Priority: -10

Package: gnupg2:i386
Pin: release n=trusty
Pin-Priority: 900

Package: gnupg-agent:i386
Pin: release n=trusty
Pin-Priority: 900

Package: gnupg2
Pin: release n=trusty
Pin-Priority: 900

Package: gnupg-agent
Pin: release n=trusty
Pin-Priority: 900
EOF
  sudo apt-get update
  sudo apt-get install -y gnupg2 gnupg-agent
  if [ ! -f /usr/bin/gpg1 ] ;  then
    sudo mv /usr/bin/gpg /usr/bin/gpg1
  fi
  sudo ln -nsf /usr/bin/gpg2 /usr/local/bin/gpg
  hash -r
)
which docker > /dev/null || (
  sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common  
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
  sudo apt-get update
  sudo apt-get install -y docker-ce
  if id vagrant ; then
    sudo usermod -aG docker vagrant
    echo "Before using docker as the vagrant user, you will need to logout and login again to obtain a shell that belongs to the docker group."
  fi
)
which docker-compose > /dev/null || (
  sudo curl -Lo /usr/local/bin/docker-compose https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m`
  sudo chmod ugo+rx /usr/local/bin/docker-compose
)
which docker-machine > /dev/null || (
  sudo curl -Lo /usr/local/bin/docker-machine https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m`
  sudo chmod ugo+rx /usr/local/bin/docker-machine
)
# Install a simple entropy gathering daemon, to speed up key generation
which haveged > /dev/null || (
  sudo apt-get install -y haveged
)
