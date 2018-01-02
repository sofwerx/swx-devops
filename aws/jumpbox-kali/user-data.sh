#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

mkdir -p /etc/dhcp/dhclient-exit-hooks.d/ 
cat <<EOF > /etc/dhcp/dhclient-exit-hooks.d/sethostname
if [ -n '$${hostname}' -a '$${hostname}' != "\$\$"'{hostname}' ]; then
  hostname $${hostname}
fi
chmod +x /etc/dhcp/dhclient-exit-hooks.d/sethostname
EOF

if [ ! -f /.donotdeleteme ]; then
  touch /.donotdeleteme

  ## Discover public and private IPv4 addresses for this instance
  PUBLIC_IPV4="$(curl -qs http://169.254.169.254/latest/meta-data/public-ipv4)"
  PRIVATE_IPV4="$(curl -qs http://169.254.169.254/latest/meta-data/local-ipv4)"

  mac=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/ | head -1 | cut -d/ -f1)
  PUBLIC_IPV6=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$mac/ipv6s | head -1 | cut -d: -f1-4)

  echo "iface eth0 inet6 dhcp" > /etc/network/interfaces.d/60-default-with-ipv6.cfg
  sudo dhclient -6

  ## Install some extra things
  sudo apt-get update
  export DEBIAN_FRONTEND=noninteractive
  sudo -E apt-get install -y fail2ban dnsmasq

  # Deal with AWS split-horizon DNS and using both IPV4 and IPV6 DNS servers

  # Disable resolvconf updates, because we can't have nice things.
  resolvconf --disable-updates

  ln -sf /var/run/resolvconf/interface/eth0.dhclient /var/run/dnsmasq/resolv.conf

  domains="$(grep ^domain /var/run/dnsmasq/resolv.conf | cut -d' ' -f2-)"
  servers="$(grep ^nameserver /var/run/dnsmasq/resolve.conf | cut -d' ' -f2-)"

  cat <<EOC > /etc/dnsmasq.conf
interface=*
port=53
bind-interfaces
user=dnsmasq
group=nogroup
resolv-file=/var/run/dnsmasq/resolv.conf
pid-file=/var/run/dnsmasq/dnsmasq.pid
domain-needed
all-servers
EOC

  ## Make sure we handle split-horizon for both ec2.internal and amazonaws.com
  for domain in $domains amazonaws.com ; do
    # Route ec2.internal to AWS servers by default
    for server in $servers; do
      echo 'server=/'"$domain"'/'"$server" >> /etc/dnsmasq.conf
    done
  done

  # Route all other queries, simultaneously, to both ipv4 and ipv6 DNS servers at Google
  for server in 8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844 ; do
    echo 'server=/*/'"$server" >> /etc/dnsmasq.conf
  done

  cat <<EOR > /etc/resolv.conf
search $domains
nameserver $PRIVATE_IPV4
EOR

  /etc/init.d/dnsmasq restart

  ## Install docker and enable it to use the IPV6 addresses
  apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

  add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

  apt-get update
  apt-get install -y linux-image-aws
  apt-get install -y docker-ce
  usermod -a -G docker debian
  echo "User debian added to docker group. You may wish to re-login to avoid using sudo docker."  |wall

fi

if ! grep kali /etc/apt/sources.list ; then
  ### Install needed packages
  apt-get update
  apt-get install -y dirmngr

  ### Add the Kali Linux GPG keys to aptitude ###
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ED444FF07D8D0BF6

  ### Replace the Debian repos with Kali repos ###
  mv /etc/apt/sources.list /etc/apt/sources.list.debian
  cat <<EOF > /etc/apt/sources.list
deb http://http.kali.org/kali kali-rolling main non-free contrib
# deb-src http://http.kali.org/kali kali-rolling main non-free contrib
EOF

  ### Update and install base packages ###
  apt-get update
  apt-get -y upgrade
  apt-get -y dist-upgrade
  apt-get -y autoremove --purge
  apt-get -y install kali-linux

  ### Downgrade specific packages to their Kali Linux versions ###
  ### * Commented out since this is currently no longer necessary (2017-09-17).
  ###   Leaving it for future reference just in case.
  #apt-get -y --force-yes install tzdata=2015d-0+deb8u1
  #apt-get -y --force-yes install libc6=2.19-18
  #apt-get -y --force-yes install systemd=215-17+deb8u1 libsystemd0=215-17+deb8u1
  #
  ### Double-check that nothing else needs to be updated ###
  #apt-get update
  #apt-get -y upgrade
  #apt-get -y dist-upgrade

  ### Clean up ###
  apt-get -y autoremove --purge
  apt-get clean
fi

export USER_NAME=manager
export USER_HOME=/home/manager

if ! id $USER_NAME ; then
  groupadd -g 1001 $USER_NAME
  useradd -g 1001 -u 1001 -d $USER_HOME -s /bin/bash -m $USER_NAME
fi

usermod -aG sudo $USER_NAME
usermod -aG admin $USER_NAME
usermod -aG docker $USER_NAME

# Add ssh key trust
mkdir -p ${USER_HOME}/.ssh
chown ${USER_NAME}.${USER_NAME} ${USER_HOME}/.ssh
chmod 700 ${USER_HOME}/.ssh
AUTHORIZED_KEYS_FILE=$(mktemp /tmp/authorized_keys.XXXXXXXX)
(
  cat /home/debian/.ssh/authorized_keys
  curl -sL https://github.com/ianblenke.keys
  curl -sL https://github.com/tabinfl.keys
  curl -sL https://github.com/ahernmikej.keys
  curl -sL https://github.com/camswx.keys
) | sort | uniq > ${AUTHORIZED_KEYS_FILE}
mv ${AUTHORIZED_KEYS_FILE} ${USER_HOME}/.ssh/authorized_keys
chown ${USER_NAME}.${USER_NAME} ${USER_HOME}/.ssh/authorized_keys
chmod 600 ${USER_HOME}/.ssh/authorized_keys

