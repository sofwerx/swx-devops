#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

if which docker ; then
  docker stop $(docker ps -aq)
fi

# Mount the EBS /var/lib/docker volume
if [ ! -f /var/lib/docker/.donotdeleteme ]; then
  mkdir -p /var/lib/docker
  if ! mount /dev/xvdi /var/lib/docker; then
    mkfs -t ext4 /dev/xvdi
    mount /dev/xvdi /mnt
    rsync -SHPaxv /var/lib/docker/ /mnt/
    umount /mnt
    if ! grep -e ^/dev/xvdi /etc/fstab; then
      echo "/dev/xvdi /var/lib/docker	ext4	defaults	0	2" >> /etc/fstab
    fi
    mount /var/lib/docker
    touch /var/lib/docker/.donotdeleteme
  fi
fi

if which docker ; then
  docker start $(docker ps -aq)
fi

# Mount the EBS /home volme
if [ ! -f /home/.donotdeleteme ]; then
  mkdir -p /home
  if ! mount /dev/xvdh /home; then
    mkfs -t ext4 /dev/xvdh
    mount /dev/xvdh /mnt
    rsync -SHPaxv /home/ /mnt/
    umount /mnt
    if ! grep -e ^/dev/xvdh /etc/fstab; then
      echo "/dev/xvdh /home	ext4	defaults	0	2" >> /etc/fstab
    fi
    mount /home
    touch /home/.donotdeleteme
  fi
fi

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

mkdir -p /var/run/dnsmasq/
if [ ! -f /var/run/dnsmasq/resolv.conf ] ; then
  cp /etc/resolv.conf /var/run/dnsmasq/resolv.conf
fi

domains="$(grep domain-name /var/lib/dhcp/dhclient.eth0.leases | awk '{print $3}' | cut -d';' -f1 | grep '"' | cut -d'"' -f2)"
servers="$(grep domain-name-server /var/lib/dhcp/dhclient.eth0.leases | awk '{print $3}' | cut -d';' -f1)"

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

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

add-apt-repository \
 "deb [arch=amd64] https://download.docker.com/linux/debian \
 $(lsb_release -cs) \
 stable"

apt-get update
apt-get install -y linux-image-aws
apt-get install -y docker-ce
usermod -a -G docker admin

USER_NAME=${USER_NAME:-manager}
USER_HOME=${USER_HOME:-/home/${USER_NAME}}
if ! id $USER_NAME ; then
  groupadd -g 1001 $USER_NAME
  useradd -g 1001 -u 1001 -d $USER_HOME -s /bin/bash -m $USER_NAME
  usermod -aG sudo $USER_NAME
  usermod -aG admin $USER_NAME
  usermod -aG docker $USER_NAME
fi

# Add ssh key trusts for manager user
mkdir -p ${USER_HOME}/.ssh
chown ${USER_NAME}.${USER_NAME} ${USER_HOME}/.ssh
chmod 700 ${USER_HOME}/.ssh
AUTHORIZED_KEYS_FILE=$(mktemp /tmp/authorized_keys.XXXXXXXX)
(
  if [ -f /home/admin/.ssh/authorized_keys ] ; then cat /home/admin/.ssh/authorized_keys ; fi
  if [ -f /home/${USER_NAME}/.ssh/authorized_keys ] ; then cat /home/${USER_NAME}/.ssh/authorized_keys ; fi
  curl -sL https://github.com/ianblenke.keys
  curl -sL https://github.com/tabinfl.keys
  curl -sL https://github.com/ahernmikej.keys
  curl -sL https://github.com/camswx.keys
) | sort | uniq > ${AUTHORIZED_KEYS_FILE}
mv ${AUTHORIZED_KEYS_FILE} ${USER_HOME}/.ssh/authorized_keys
chown ${USER_NAME}.${USER_NAME} ${USER_HOME}/.ssh/authorized_keys
chmod 600 ${USER_HOME}/.ssh/authorized_keys

