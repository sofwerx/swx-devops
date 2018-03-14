# swx-tegra0

This is a NVidia Jetson TX2 developer kit with docker used in Mad Jack's range.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.74 --generic-ssh-port 30022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 30376 --engine-storage-driver overlay2 swx-u-ub-tegra0
    swx dm import swx-u-ub-tegra0

