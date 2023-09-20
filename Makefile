VERSIONS := $(shell cat VERSIONS)

dc-build:
	docker-compose -f docker-compose-dev.yml build backup

dc-up: dc-build
	docker-compose -f docker-compose-dev.yml up -d backup

dc-bash:
	docker-compose -f docker-compose-dev.yml exec backup bash

dc-stop:
	docker-compose -f docker-compose-dev.yml stop backup

login:
	docker login

versions: login
	for version in $(VERSIONS); do \
		docker build . --build-arg POSTGRES_VERSION=$$version -t pg_dump:$$version ;\
	done
	docker build . --build-arg POSTGRES_VERSION=$(lastword $(VERSIONS)) -t pg_dump:latest

push: versions
	for version in $(VERSIONS); do \
		docker push martlark/pg_dump:$$version; \
	done
	docker push martlark/pg_dump:latest
