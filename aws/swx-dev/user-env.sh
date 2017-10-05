#!/bin/bash

while ! dmesg | grep xvdh ; do
  echo "Waiting for home EBS volume to attach"
  sleep 1
done

while ! dmesg | grep xvdi ; do
  echo "Waiting for docker EBS volume to attach"
  sleep 1
done

# Mount the EBS /home volume
if [ ! -f /home/.donotdeleteme ]; then
  mkdir -p /home
  if ! mount /dev/xvdh /home; then
    mkfs -t ext4 /dev/xvdh
    mount /dev/xvdh /mnt
    rsync -SHPaxv /home/ /mnt/
    umount /mnt
    mount /dev/xvdh /home
    touch /home/.donotdeleteme
  fi
fi

# Mount the EBS /var/lib/docker volume
if [ ! -f /var/lib/docker/.donotdeleteme ]; then
  mkdir -p /var/lib/docker
  if ! mount /dev/xvdi /var/lib/docker; then
    mkfs -t ext4 /dev/xvdi
    mount /dev/xvdi /var/lib/docker
    touch /var/lib/docker/.donotdeleteme
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
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
  echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > /etc/apt/sources.list.d/docker.list
  apt-get update
  apt-get install -y linux-image-extra-$(uname -r)
  apt-get install -y docker-engine
  usermod -a -G docker ubuntu
  echo "User ubuntu added to docker group. You may wish to re-login to avoid using sudo docker."  |wall

  # Install dokku if it hasn't been yet
  if ! id dokku; then
    wget https://raw.githubusercontent.com/dokku/dokku/v0.10.5/bootstrap.sh;
    sudo DOKKU_TAG=v0.10.5 bash bootstrap.sh
  fi

fi

