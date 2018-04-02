all:
	COMPOSE_PROJECT_NAME=public COMPOSE_FILE=public.yml docker-compose build
	COMPOSE_PROJECT_NAME=public COMPOSE_FILE=public.yml docker-compose up -d

clean:
	COMPOSE_PROJECT_NAME=public COMPOSE_FILE=public.yml docker-compose stop || true
	COMPOSE_PROJECT_NAME=public COMPOSE_FILE=public.yml docker-compose rm -f || true
	docker network rm public_default public_vlan20 || true
	docker volume rm public_dnsmasq-leases || true

