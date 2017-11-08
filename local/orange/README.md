# orange

This is an 8-node tranquilpc in the SWX Underground "nerd herd" data science pit.

## environment

First, switch to the orange environment:

    [sofwerx::] icbvtcmbp:orange ianblenke$ swx environment switch orange
    [sofwerx:orange:] icbvtcmbp:orange ianblenke$

Before using docker commands in this directory, please be sure to source the dm of a node in the cluster:

    [sofwerx:orange:] icbmbp:orange ianblenke$ swx dm env swx-r-u-node0
    [sofwerx:orange:swx-r-u-node0] icbmbp:orange ianblenke$

Due to `DOCKER_COMPOSE=orange.yml` in the orange environment, the `orange.yml` here is the `docker-compose.yml` that is used when a `swx dc` or `docker-compose` is run.

## ELK

Elasticsearch / Logstash / Kibana (ELK) was deployed from here using:

    docker stack deploy -c orange.yml elk

### Related:

ELK on docker swarm:

- https://github.com/ahromis/swarm-elk
- https://botleg.com/stories/log-management-of-docker-swarm-with-elk-stack/

