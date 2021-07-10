login:
	docker login

versions:
	docker build . --build-arg POSTGRES_VERSION=12.1 -t martlark/pg_dump:9.6
	docker build . --build-arg POSTGRES_VERSION=12.1 -t martlark/pg_dump:10.17
	docker build . --build-arg POSTGRES_VERSION=12.1 -t martlark/pg_dump:11.12
	docker build . --build-arg POSTGRES_VERSION=12.1 -t martlark/pg_dump:12.1
	docker build . --build-arg POSTGRES_VERSION=12.2 -t martlark/pg_dump:12.2
	docker build . --build-arg POSTGRES_VERSION=12.3 -t martlark/pg_dump:12.3
	docker build . --build-arg POSTGRES_VERSION=12.3 -t martlark/pg_dump:12.4
	docker build . --build-arg POSTGRES_VERSION=12.3 -t martlark/pg_dump:12.5
	docker build . --build-arg POSTGRES_VERSION=12.3 -t martlark/pg_dump:12.6
	docker build . --build-arg POSTGRES_VERSION=12.3 -t martlark/pg_dump:12.7
	docker build . --build-arg POSTGRES_VERSION=12.3 -t martlark/pg_dump:13.0
	docker build . --build-arg POSTGRES_VERSION=12.3 -t martlark/pg_dump:13.1 -t martlark/pg_dump:latest

push:
	docker push martlark/pg_dump:9.6
	docker push martlark/pg_dump:10.17
	docker push martlark/pg_dump:11.12
	docker push martlark/pg_dump:12.1
	docker push martlark/pg_dump:12.2
	docker push martlark/pg_dump:12.3
	docker push martlark/pg_dump:12.4
	docker push martlark/pg_dump:12.5
	docker push martlark/pg_dump:12.6
	docker push martlark/pg_dump:12.7
	docker push martlark/pg_dump:13.0
	docker push martlark/pg_dump:13.1
	docker push martlark/pg_dump:latest
