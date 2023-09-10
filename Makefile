VERSIONS := $(shell cat VERSIONS)

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
