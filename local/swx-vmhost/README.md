# swx-vmhost

This is a system76 silverback in the NerdHerd room, with two nVidia GPU cards.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.82 --generic-ssh-port 10022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 10376 --engine-storage-driver zfs swx-u-ub-vmhost
    swx dm import swx-u-ub-vmhost

