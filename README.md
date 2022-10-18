martlark/pg_dump
================

Postgres Docker image with pg_dump running as a cron task. Find the image
here: https://hub.docker.com/repository/docker/martlark/pg_dump

## Usage

Import a postgreSQL database into this container and mount a volume to the containers `/dump` folder. 
Backups will appear in this volume. Optionally set up cron job schedule (default is `0 1 * * *` - 
runs every day at 1:00 am).

## Environment Variables:

| Variable                 | Alias        | Required?  | Default               | Description                                                                   |
|--------------------------|:-------------|:-----------|:----------------------|:------------------------------------------------------------------------------|
| `PGUSER`                 | `None`       | Optional   | postgres              | The user for accessing the database                                           |
| `POSTGRES_PASSWORD`      | `PGPASSWORD` | Optional   | `None`                | The password for accessing the database                                       |
| `POSTGRES_DB`            | `PGDB`       | Optional   | postgres              | The name of the database                                                      |
| `PGHOST`                 | `None`       | Optional   | db/localhost | The hostname of the database. `db` is the default if RUN_DOUBLE, `localhost` otherwise |
| `PGPORT`                 | `None`       | Optional   | `5432`                | The port for the database                                                     |
| `CRON_SCHEDULE`          | `None`       | Required   | 0 1 * * *             | The cron schedule at which to run the pg_dump                                 |
| `RETAIN_COUNT`           | `None`       | Optional   | `None`                | Optionally, a number to retain, delete older files                            |
| `PREFIX`                 | `None`       | Optional   | dump                  | Optionally, prefix for dump files                                             |
| `PGDUMP`                 | `None`       | Optional   | /dump                 | Optionally, define a different location to dump your backups.                 |
| `LOGFIFO`                | `None`       | Optional   | `${PGDUMP}/cron.fifo` | Location to write cron logs to.                                               |
| `PG_LOG`                 | `None`       | Optional   | `None`                | Optionally, set any value to view this env inside of the container            |
| `COMMAND`                | `None`       | Optional   | `dump-cron` | Options: `dump` dumps the database and exit, `dump-cron` creates a cron job and runs    |
| `RUN_DOUBLE`             | `None`       | Optional   | `true`        | "true" does not enable the PostgreSQL database within this container, "false" does    |
| `POSTGRES_PASSWORD_FILE` | `None`       | Recomended | `None`                | Location of the password file. Overrides `POSTGRES_PASSWORD` and `PGPASSWORD` |

## Optional Controls

By default, this container executes as the postgres user. Using a non-root user for your container
is always a safer route and should be one of your first modifications. The POSTGRES_PASSWORD field can 
either be set via environment variable or via docker secrets. Again, for security reasons, it is
always recommended to use docker secrets for security concerns. If using the docker secrets, set the
POSTGRES_PASSWORD_FILE field, warning this overrides POSTGRES_PASSWORD and PGPASSWORD. An example secrets 
file can be found below in the docker-compose area. The default for PGHOST is dependant on if RUN_DOUBLE 
is set; if RUN_DOUBLE is "true" than "db" is the default, if RUN_DOUBLE is "false" than "localhost" is
the default. PGPORT is the exposed port in the container, so it is recommended not to change this. 

## Docker Compose

### Example of running with a single postgreSQL container.

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
       - PGDATA=/data     # Where the SQL DB will store itself & backups will dump
       - RETAIN_COUNT=1   # Keep this number of backups
       - RUN_DOUBLE=false # Run postgresDB as part of this container
       - POSTGRES_DB=postgres    # The name of the database to dump
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

### Example of running with separate services.

```yaml
version: "3.9"
services:
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
      - PGPASSWORD=SumPassw0rdHere
      - CRON_SCHEDULE=0 3 * * * # Every day at 3am
      - RETAIN_COUNT=1 # Keep this number of backups
    volumes:
      - ./persistent/data:/dump
```

Tagged versions
===============

Versions available on docker hub are:

    9.6 10.17 11.12 12.1 12.2 12.3 12.4 12.5 12.6 12.7 12.10 13.0 13.1 13.6 14.2
	
    latest is 14.2

