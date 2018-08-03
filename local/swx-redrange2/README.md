# swx-redrange2

This is a system76 laptop in the Mad Jack's range pit.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.74 --generic-ssh-port 52022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 52376 --engine-storage-driver overlay2 swx-m-ub-redrange2
    swx dm import swx-m-ub-redrange2

