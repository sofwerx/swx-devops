#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

dpkg --configure -a --force-all

### Update and install base packages ###
apt-get update
apt-get -y upgrade
apt-get -y dist-upgrade
apt-get -y autoremove --purge

apt-get update
apt-get install -y xrdp

# Ensure `allowed_users=anybody` in /etc/X11/Xwrapper.config
if ! grep -e ^allowed_users=anybody /etc/X11/Xwrapper.config ; then
  if grep -e ^allowed_users /etc/X11/Xwrapper.config; then
    sed -i -e 's/^needs_root_rights=.*$/allowed_users=anybody' /etc/X11/Xwrapper.config
  else
    echo "allowed_users=anybody" >> /etc/X11/Xwrapper.config 
  fi
fi

# Ensure `needs_root_rights=no` in /etc/X11/Xwrapper.config
if ! grep -e ^needs_root_rights=no /etc/X11/Xwrapper.config ; then
  if grep -e ^needs_root_rights /etc/X11/Xwrapper.config; then
    sed -i -e 's/^needs_root_rights=.*$/needs_root_rights=no/' /etc/X11/Xwrapper.config
  else
    echo needs_root_rights=no >> /etc/X11/Xwrapper.config
  fi
fi

systemctl restart xrdp
systemctl restart xrdp-sesman

apt-get remove gnome-core
apt-get install -y lxde-core lxde desktop-base
update-alternatives –config x-session-manager /usr/bin/startlxde

### Clean up ###
apt-get -y autoremove --purge
apt-get clean

