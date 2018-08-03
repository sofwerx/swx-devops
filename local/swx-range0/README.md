# swx-range0

This is a mint popOS box that is being used for gammarf.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.74 --generic-ssh-port 10022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 10376 --engine-storage-driver overlay2 swx-u-ub-range0
    swx dm import swx-u-ub-range0

