martlark/pg_dump
================

Postgres Docker image with pg_dump running as a cron task. Find the image
here: https://hub.docker.com/repository/docker/martlark/pg_dump

## Usage

Import a postgreSQL database into this container and mount a volume to the containers `/dump` folder. 
Backups will appear in this volume. Optionally set up cron job schedule (default is `0 1 * * *` - 
runs every day at 1:00 am).

## Environment Variables:

| Variable        | Required? | Default   | Description                                                         |
|-----------------|:----------|:----------|:--------------------------------------------------------------------|
| `PGUSER`        | Optional  | postgres  | The user for accessing the database                                 |
| `PGPASSWORD`    | Optional  | `None`    | The password for accessing the database                             |
| `POSTGRES_DB`   | Optional  | postgres  | The name of the database                                            |
| `PGHOST`        | Optional  | localhost | The hostname of the database                                        |
| `PGPORT`        | Optional  | `5432`    | The port for the database                                           |
| `CRON_SCHEDULE` | Required  | 0 1 * * * | The cron schedule at which to run the pg_dump                       |
| `RETAIN_COUNT`  | Optional  | `None`    | Optionally, a number to retain, delete older files                  |
| `PREFIX`        | Optional  | dump      | Optionally, prefix for dump files                                   |
| `PGDUMP`        | Optional  | /dump     | Optionally, define a different location to dump your backups.       |
| `LOGFIFO`       | Optional  | `${PGDUMP}/cron.fifo` | Location to write cron logs to.                         |
| `POSTGRES_PASSWORD_FILE`    | Recomended  | `/run/secrets/db_password` | Location of the password file          |
| `PG_LOG`        | Optional  | `None`    | Optionally, set any value to view this env inside of the container  |

## Optional Controls

By default, this container executes as the postgres user. Using a non-root user for your container
is always a safer route and should be one of your first modifications. The PGPASSWORD field can 
either be set via environment variable or via docker secrets. Again, for security reasons, it is
always recommended to use docker secrets for security concerns. An example secrets file can be 
found below in the docker-compose area. PGPORT is the exposed port in the container, so it is 
recommended not to change this. 

Docker Compose
==============

Example with docker-compose:

```yaml
version: "3.9"
services:
   database:
     image: martlark/pg_dump:12.1
     container_name: postgres-backup
     volumes:
       - postgres-data:/data:rw
       - postgres-backup:/dump:rw
     environment:
       - PGDATA=/data   # Where the SQL DB will store itself & backups will dump
       - RETAIN_COUNT=1 # Keep this number of backups
       - PGDB=postgres  # The name of the database to dump
       - CRON_SCHEDULE=0 3 * * * # Every day at 3am
       - POSTGRES_PASSWORD_FILE=/run/secrets/db_password # The password file
     restart: unless-stopped
     secrets:
       - db_password # Contains the PSQL password

volumes:
   postgres-data:
      external: true
   postgres-backup:
      external: true

secrets:
   db_password:
     file: db_password.txt
```

Secrets file:
```text
PGPASSWORD=SumPassw0rdHere
```

Tagged versions
===============

Versions available on docker hub are:

    9.6 10.17 11.12 12.1 12.2 12.3 12.4 12.5 12.6 12.7 12.10 13.0 13.1 13.6 14.2
	
    latest is 14.2

