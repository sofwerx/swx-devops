# swx-range2

This is a mint box acting as a packet capture node for the SWX-BRange wifi traffic.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.74 --generic-ssh-port 12022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 12376 --engine-storage-driver overlay2 swx-u-ub-range2
    swx dm import swx-u-ub-range2

