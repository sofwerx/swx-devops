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

    [sofwerx::] icbmbp:orange ianblenke$ swx dm env swx-r-u-orange0
    [sofwerx:orange:swx-r-u-orange0] icbmbp:orange ianblenke$

Due to `DOCKER_COMPOSE=orange.yml` in the orange environment, the `orange.yml` here is the `docker-compose.yml` that is used when a `docker-compose` is run.

