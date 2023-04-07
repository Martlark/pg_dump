login:
	docker login

versions: login
	docker build . --build-arg POSTGRES_VERSION=11.19 -t martlark/pg_dump:11.19
	docker build . --build-arg POSTGRES_VERSION=12.14 -t martlark/pg_dump:12.14
	docker build . --build-arg POSTGRES_VERSION=13.10 -t martlark/pg_dump:13.10
	docker build . --build-arg POSTGRES_VERSION=14.7 -t martlark/pg_dump:14.7
	docker build . --build-arg POSTGRES_VERSION=15.2 -t martlark/pg_dump:15.2 -t martlark/pg_dump:latest

push: versions
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
	docker push martlark/pg_dump:12.10
	docker push martlark/pg_dump:13.0
	docker push martlark/pg_dump:13.1
	docker push martlark/pg_dump:13.6
	docker push martlark/pg_dump:14.2
	docker push martlark/pg_dump:latest
