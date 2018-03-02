# swx-range1

This is a mint popOS box that is being used for gammarf.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.74 --generic-ssh-port 11022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 11376 --engine-storage-driver overlay2 swx-u-ub-range1
    swx dm import swx-u-ub-range1

