# orange

This is an 8-blade tranquilpc in the SWX Underground "nerd herd" data science pit.

Each blade has 64G of DDR4 RAM, an 8 core Xeon, and two drives:

- /dev/sda - 120G SSD
- /dev/sdb - 1TB SSD

These blades are running Ubuntu 18.04 Bionic:

- `swx-u-ub-orange0` [192.168.1.120]
- `swx-u-ub-orange1` [192.168.1.121]
- `swx-u-ub-orange2` [192.168.1.122]
- `swx-u-ub-orange3` [192.168.1.123]
- `swx-u-ub-orange4` [192.168.1.124]
- `swx-u-ub-orange5` [192.168.1.125]
- `swx-u-ub-orange6` [192.168.1.126]
- `swx-u-ub-orange7` [192.168.1.127]

## environment

Before using docker commands in this directory, please be sure to source the dm of a node in the cluster:

    [sofwerx::] icbmbp:swx-orange ianblenke$ swx dm env swx-r-u-orange0
    [sofwerx:orange:swx-r-u-orange0] icbmbp:swx-orange ianblenke$

Due to `COMPOSE_FILE=swx-orange.yml` in the swx-orange environment, the `swx-orange.yml` here is the `docker-compose.yml` that is used when a `docker-compose` is run.

## dm creation

    docker-machine create -d generic --generic-ip-address 172.109.152.124 --generic-ssh-port 50022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 50376 --engine-storage-driver zfs swx-u-ub-orange0
    docker-machine create -d generic --generic-ip-address 172.109.152.124 --generic-ssh-port 51022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 51376 --engine-storage-driver zfs swx-u-ub-orange1
    docker-machine create -d generic --generic-ip-address 172.109.152.124 --generic-ssh-port 52022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 52376 --engine-storage-driver zfs swx-u-ub-orange2
    docker-machine create -d generic --generic-ip-address 172.109.152.124 --generic-ssh-port 53022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 53376 --engine-storage-driver zfs swx-u-ub-orange3
    docker-machine create -d generic --generic-ip-address 172.109.152.124 --generic-ssh-port 54022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 54376 --engine-storage-driver zfs swx-u-ub-orange4
    docker-machine create -d generic --generic-ip-address 172.109.152.124 --generic-ssh-port 55022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 55376 --engine-storage-driver zfs swx-u-ub-orange5
    docker-machine create -d generic --generic-ip-address 172.109.152.124 --generic-ssh-port 56022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 56376 --engine-storage-driver zfs swx-u-ub-orange6
    docker-machine create -d generic --generic-ip-address 172.109.152.124 --generic-ssh-port 57022 --generic-ssh-key ${devops}/secrets/ssh/sofwerx --generic-ssh-user swxadmin --generic-engine-port 57376 --engine-storage-driver zfs swx-u-ub-orange7

## docker swarm

    docker node update --label-add orange1 swx-u-ub-orange1
    docker node update --label-add orange2 swx-u-ub-orange2
    docker node update --label-add orange3 swx-u-ub-orange3
    docker node update --label-add orange4 swx-u-ub-orange4
    docker node update --label-add orange5 swx-u-ub-orange5
    docker node update --label-add orange6 swx-u-ub-orange6
    docker node update --label-add orange7 swx-u-ub-orange7


