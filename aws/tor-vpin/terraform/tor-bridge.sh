#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

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
  curl -sL https://github.com/Shad0wSt4R.keys
) | sort | uniq > ${AUTHORIZED_KEYS_FILE}
mv ${AUTHORIZED_KEYS_FILE} ${USER_HOME}/.ssh/authorized_keys
chown ${USER_NAME}.${USER_NAME} ${USER_HOME}/.ssh/authorized_keys
chmod 600 ${USER_HOME}/.ssh/authorized_keys

