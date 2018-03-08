# swx-bluerange0

This is a system76 laptop next to range2 that is likewise packet capturing.

## dm creation

    docker-machine create -d generic --generic-ip-address 192.168.0.121 --generic-ssh-port 22 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 22376 --engine-storage-driver overlay2 swx-u-ub-bluerange0
    swx dm import swx-u-ub-bluerange0

