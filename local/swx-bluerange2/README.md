# swx-bluerange2

This is a system76 "sociblue" laptop that Emerson is using.

## dm creation

    docker-machine create -d generic --generic-ip-address 192.168.0.124 --generic-ssh-port 22 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 42376 --engine-storage-driver overlay2 swx-u-ub-bluerange2
    swx dm import swx-u-ub-bluerange2

