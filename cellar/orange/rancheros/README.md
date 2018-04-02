# rancheros

This is documentation to how the 8 blades in the Sofwerx "Orange" TranquilPC cluster chassis were rebuilt with raw-metal RancherOS.

# Prepare a node with rancheros

1. Create and boot to a rancher USB stick

Download the rancheros.iso from the Rancher website.

Using Etcher ([etcher.io](https://etcher.io)), flash it to a USB stick.

Boot to the USB stick.

2. Install rancher to disk:

RancherOS really needs two disks to install.
- A "syslinux" boot drive, that is autopartitioned and formatted with a whole disk msdos partition as sda1
- A "RANCHER_STATE" labeled persistence drive, that we pre-format with ext4 (though it will merrily autoformat if you don't want the ext4 tweaks).

I could not, for the life of me, find a way to tell RancherOS to _not_ reformat the syslinux install disk for the base OS.
Moreover, if you tell it to use the same drive for the state persistence volume, it will merrily reformat it trampling all over itself.

This is not a problem with cloud provisioned RancherOS instances where you can carve out a small operating system drive just for syslinux.
This appears to mostly be a problem with raw-metal servers like this.

Just use two disks with RancherOS, and avoid wasting your time like I did.

Wipe the partitioning off of the old 120G /dev/sda and the new 1TB /dev/sdb disks:

    sudo dd if=/dev/zero of=/dev/sda bs=1M count=1
    sudo dd if=/dev/zero of=/dev/sdb bs=1M count=1

Format the persistence volume on the second disk with some flags:

    sudo mkfs.ext4 -b 4096 -m 0 -O dir_index,filetype,sparse_super,uninit_bg -L RANCHER_STATE /dev/sdb

Create the `cloud-cloud.yml` with my github ssh keys:

    echo "#cloud-config" > cloud-config.yml
    echo "ssh_authorized_keys:" >> cloud-config.yml
    wget -q -O - https://github.com/ianblenke.keys | while read line ; do echo "- $line" >> cloud-config.yml ; done

Install rancheros to disk:

    sudo ros install -d /dev/sda --append 'console=tty1 rancher.autologin=tty1 console=ttyS1,115200n81 rancher.autologin=ttyS1 rancher.state.dev=LABEL=RANCHER_STATE' -c cloud-config.yml

3. After rebooting:

The disk booted node now has a hostname of `rancher` and a DHCP IP address.

Use `ip addr show eth0` to find the DHCP address of the node.

Locally on your dev workstation, copy up the cloud-config.yml for the instance:

    eval $(ssh-agent)
    ssh-add ~/.ssh/id_rsa-ianblenke@github.com_4096
    scp swx-u-r-node0/cloud-config.yml rancher@192.168.1.115:.

Back on the rancher console, merge that config:

    sudo ros config merge < cloud-config.yml

Then reboot the rancher server for the changes to take effect.

4. After rebooting again:

The node should now have its hostname and correct static IP address.

On the rancher console, enable docker TLS by running:

    sudo ros config set rancher.docker.tls true
    sudo ros tls gen --server -H localhost -H swx-u-r-node0 -H swx-u-r-node0.devwerx.org
    sudo system-docker restart docker
    sudo ros tls gen

Locally on your dev workstation, copy up the `rancheros2dm.sh` script and sofwerx ssh key:

    eval $(ssh-agent)
    ssh-add ~/.ssh/id_rsa-ianblenke@github.com_4096
    scp ../../../scripts/rancheros2dm.sh rancher@192.168.1.115:.
    scp ../../../secrets/ssh/ rancher@192.168.1.115:.ssh/

On the rancher console, run that script.

    sudo ./rancheros2dm.sh
    rm -f .ssh/sofwerx*

Now you will have a `dm.json` file that contains the json to be added to trousseau in [github.com/sofwerx/swx-devops](https://github.com/sofwerx/swx-devops/):

    scp rancher@192.168.1.120:dm.json /tmp/dm.json
    jq -c . < /tmp/dm.json > ../../../secrets/dm/swx-u-r-node0
    swx-devops$ trousseau set file:secrets/dm/swx-u-r-node0 "$(cat ../../../secrets/dm/swx-u-r-node0 | base64)"

The swx-devops `swx dm` will now let you source that and use the docker commands locally to talk to that rancher server.

# Configure rancheros

    sudo ros config merge < cloud-config.yml

