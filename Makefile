login:
	docker login

versions: login
	docker build . --build-arg POSTGRES_VERSION=11.19 -t martlark/pg_dump:11.19
	docker build . --build-arg POSTGRES_VERSION=12.14 -t martlark/pg_dump:12.14
	docker build . --build-arg POSTGRES_VERSION=13.10 -t martlark/pg_dump:13.10
	docker build . --build-arg POSTGRES_VERSION=14.7 -t martlark/pg_dump:14.7
	docker build . --build-arg POSTGRES_VERSION=15.2 -t martlark/pg_dump:15.2 -t martlark/pg_dump:latest

push: versions
	docker push martlark/pg_dump:11.19
	docker push martlark/pg_dump:12.14
	docker push martlark/pg_dump:13.10
	docker push martlark/pg_dump:14.7
	docker push martlark/pg_dump:latest
