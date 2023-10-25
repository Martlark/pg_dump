VERSIONS := $(shell cat VERSIONS)
REVISION := b
NAME := "martlark/pg_dump"

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
		docker image build . --build-arg POSTGRES_VERSION=$$version -t $(NAME):$$version-$(REVISION) -t $(NAME):$$version ;\
	done
	docker image build . --build-arg POSTGRES_VERSION=$(lastword $(VERSIONS)) -t $(NAME):latest

push: version login
	for version in $(VERSIONS); do \
		docker image push $(NAME):$$version-$(REVISION); \
		docker image push $(NAME):$$version; \
	done
	docker image push $(NAME):latest
