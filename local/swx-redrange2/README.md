# swx-redrange2

This is a system76 laptop in the Mad Jack's range pit.

## dm creation

    docker-machine create -d generic --generic-ip-address 192.168.0.131 --generic-ssh-port 22 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 52376 --engine-storage-driver overlay2 swx-m-ub-redrange2
    swx dm import swx-m-ub-redrange2

