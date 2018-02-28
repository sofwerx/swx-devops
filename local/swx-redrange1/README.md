# swx-redrange1

This is a system76 laptop used for SDR capture currently in the bluerange pit.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.74 --generic-ssh-port 51022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 51376 --engine-storage-driver overlay2 swx-m-ub-redrange1
    swx dm import swx-m-ub-redrange1

