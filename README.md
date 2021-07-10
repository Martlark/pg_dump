martlark/pg_dump
================

Postgres Docker image with pg_dump running as a cron task. Find the image,
here: https://hub.docker.com/repository/docker/martlark/pg_dump

## Usage

Attach a target postgres container to this container and mount a volume 
to a container's `/dump` folder. Backups will appear in this volume. 
Optionally set up cron job schedule (default is `0 1 * * *` - runs every day at 1:00 am).

## Environment Variables:
| Variable | Required? | Default | Description |
| -------- |:--------- |:------- |:----------- |
| `PGUSER` | Required | postgres | The user for accessing the database |
| `PGPASSWORD` | Optional | `None` | The password for accessing the database |
| `PGDB` | Optional | postgres | The name of the database |
| `PGHOST` | Optional | db | The hostname of the database |
| `PGPORT` | Optional | `5432` | The port for the database |
| `CRON_SCHEDULE` | Required | 0 1 * * * | The cron schedule at which to run the pg_dump |
| `RETAIN_COUNT` | Optional | `None` | Optionally, delete older files |
| `PREFIX` | Optional | dump | Optionally, prefix for dump files |

Docker Compose
==============

Example with docker-compose:

```yaml

database:
  image: postgres:12.1
  volumes:
    - ./persistent/data:/var/lib/postgresql/data
  environment:
    - POSTGRES_PASSWORD=SumPassw0rdHere
    - POSTGRES_DB=postgres
  restart: unless-stopped

postgres-backup:
  image: martlark/pg_dump:12.1
  container_name: postgres-backup
  links:
    - database:db # Maps as "db"
  environment:
    - PGUSER=postgres
    - PGPASSWORD=SumPassw0rdHere
    - CRON_SCHEDULE=0 3 * * * # Every day at 3am
    - RETAIN_COUNT=1 # Keep this number of backups
    - PGDB=postgres # The name of the database to dump 
  #  - PGHOST=db # The hostname of the PostgreSQL database to dump
  volumes:
    - ./persistent/data:/dump

```
Tagged versions
===============

Versions available on docker hub are:

    9.6 10.17 11.12 12.1 12.2 12.3 12.4 12.5 12.6 12.7 13.0 13.1
	
    latest is 13.1

