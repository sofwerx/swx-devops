#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

dpkg --configure -a --force-all

### Update and install base packages ###
apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoremove --purge

# Install latest xrdp
cat <<EOF > /etc/apt/sources.list.d/xrdp.list
deb http://ppa.launchpad.net/hermlnx/xrdp/ubuntu xenial main
deb-src http://ppa.launchpad.net/hermlnx/xrdp/ubuntu xenial main
EOF
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CAB0B10F

apt-get update
apt-get install -y xrdp
systemctl restart xrdp
systemctl restart xrdp-sesman

apt-get remove gnome-core
apt-get install -y lxde-core lxde desktop-base
update-alternatives –config x-session-manager /usr/bin/startlxde

### Clean up ###
apt-get -y autoremove --purge
apt-get clean

