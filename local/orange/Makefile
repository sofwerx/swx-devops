all: consul # orange traefik elk stf # nerdherdvpn

consul:
	cd swarm ; docker stack deploy -c consul.yml consul

orange:
	cd swarm ; docker stack deploy -c orange.yml orange

traefik:
	cd swarm ; docker stack deploy -c traefik.yml traefik

elk:
	cd swarm ; docker stack deploy -c elk.yml elk

stf:
	cd swarm ; docker stack deploy -c stf.yml stf

