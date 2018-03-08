# swx-redrange1

This is a system76 laptop used for SDR capture currently in the bluerange pit.

## dm creation

    docker-machine create -d generic --generic-ip-address 192.168.0.127 --generic-ssh-port 22 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 51376 --engine-storage-driver overlay2 swx-m-ub-redrange1
    swx dm import swx-m-ub-redrange1

