# swx-bluerange0

This is a system76 laptop that is packet capturing.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.143.74 --generic-ssh-port 20022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 20376 --engine-storage-driver overlay2 swx-u-ub-bluerange0
    swx dm import swx-u-ub-bluerange0

