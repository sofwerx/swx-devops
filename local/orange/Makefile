all: orange traefik elk stf # nerdherdvpn

orange:
	cd swarm ; docker stack deploy -c orange.yml orange

traefik:
	cd swarm ; docker stack deploy -c traefik.yml traefik

elk:
	cd swarm ; docker stack deploy -c elk.yml elk

stf:
#	cd swarm ; docker stack deploy -c stf.yml stf

#nerdherdvpn:
#	cd compose; COMPOSE_FILE=swx_u_r_node0.yml docker-compose up -d
#	cd compose; COMPOSE_FILE=swx_u_r_node1.yml docker-compose up -d
#	cd compose; COMPOSE_FILE=swx_u_r_node2.yml docker-compose up -d
#	cd compose; COMPOSE_FILE=swx_u_r_node3.yml docker-compose up -d
#	cd compose; COMPOSE_FILE=swx_u_r_node4.yml docker-compose up -d
#	cd compose; COMPOSE_FILE=swx_u_r_node5.yml docker-compose up -d
#	cd compose; COMPOSE_FILE=swx_u_r_node6.yml docker-compose up -d
#	cd compose; COMPOSE_FILE=swx_u_r_node7.yml docker-compose up -d
