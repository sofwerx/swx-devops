# orange

This is an 8-blade tranquilpc in the SWX Underground "nerd herd" data science pit.

Each blade has 64G of DDR4 RAM, an 8 core Xeon, and two drives:

- /dev/sda - 120G SSD
- /dev/sdb - 1TB SSD

# OpenStack Fuel

The first blade, `swx-u-r-node0` [192.168.1.120], was deployed from a USB install of the OpenStack fuel 11.0 stable `.iso` image.

# OpenStack

The remaining blades are:

- `swx-u-r-node1` [192.168.1.121]
- `swx-u-r-node2` [192.168.1.122]
- `swx-u-r-node3` [192.168.1.123]
- `swx-u-r-node4` [192.168.1.124]
- `swx-u-r-node5` [192.168.1.125]
- `swx-u-r-node6` [192.168.1.126]
- `swx-u-r-node7` [192.168.1.127]

## environment

Before using docker commands in this directory, please be sure to source the dm of a node in the cluster:

    [sofwerx::] icbmbp:orange ianblenke$ swx dm env swx-r-u-node0
    [sofwerx:orange:swx-r-u-node0] icbmbp:orange ianblenke$

Due to `DOCKER_COMPOSE=orange.yml` in the orange environment, the `orange.yml` here is the `docker-compose.yml` that is used when a `docker-compose` is run.

## Public NAT

The (fuel-nat/)[fuel-nat/] folder contains what was used to deploy the `public-nat` container that is acting as the default route NATting gateway for the OpenStack public segment.


