all:
	@[ "$$DOCKER_MACHINE_NAME" == "swx-a-geotools1-osgeo0" ]
	@[ "$$COMPOSE_FILE" == "swx-geotools1.yml" ]
	docker-compose build osgeo
	docker-compose rm -f osgeo || true
	docker-compose up osgeo
