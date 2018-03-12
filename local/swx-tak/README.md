# swx-tak

This is a laptop at SOFWERX Underground that is acting as a TAK server.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.94 --generic-ssh-port 22 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 2376 --engine-storage-driver overlay2 swx-u-ub-tdtak
    swx dm import swx-u-ub-tdtak

