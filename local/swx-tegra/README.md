# swx-tegra

This is an updated cluster of NVidia Jetson TX2 developer kit nodes with docker used in Mad Jack's range.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.90 --generic-ssh-port 21022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user nvidia --generic-engine-port 21376 --engine-storage-driver overlay2 swx-u-ub-tegra01
    docker-machine create -d generic --generic-ip-address 172.109.143.90 --generic-ssh-port 22022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user nvidia --generic-engine-port 22376 --engine-storage-driver overlay2 swx-u-ub-tegra02
    swx dm import swx-u-ub-tegra01
    swx dm import swx-u-ub-tegra02

