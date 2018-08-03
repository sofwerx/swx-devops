# swx-range3

This is a mint box currently processing gammarf traffic.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.74 --generic-ssh-port 13022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 13376 --engine-storage-driver overlay2 swx-u-ub-range3
    swx dm import swx-u-ub-range3

