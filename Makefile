VERSIONS := $(shell cat VERSIONS)

dc-build:
	docker-compose -f docker-compose-dev.yml build backup-12-16 backup-15-2

dc-up: dc-build
	docker-compose -f docker-compose-dev.yml up -d backup-12-16 backup-15-2

dc-logs: dc-build
	docker-compose -f docker-compose-dev.yml logs -f backup-12-16 backup-15-2

dc-bash:
	docker-compose -f docker-compose-dev.yml exec backup-15-2 bash

dc-stop:
	docker-compose -f docker-compose-dev.yml stop

login:
	docker login

version:
	for version in $(VERSIONS); do \
		docker build . --build-arg POSTGRES_VERSION=$$version -t pg_dump:$$version ;\
	done
	docker build . --build-arg POSTGRES_VERSION=$(lastword $(VERSIONS)) -t pg_dump:latest

push: version login
	for version in $(VERSIONS); do \
		docker push martlark/pg_dump:$$version; \
	done
	docker push martlark/pg_dump:latest
