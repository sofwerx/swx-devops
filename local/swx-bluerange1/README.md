# swx-bluerange1

This is a system76 laptop being used in the range.

## dm creation

    docker-machine create -d generic --generic-ip-address 192.168.0.109 --generic-ssh-port 22 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 21376 --engine-storage-driver overlay2 swx-u-ub-bluerange1
    swx dm import swx-u-ub-bluerange1

