martlark/pg_dump
================

Docker image with pg_dump running as a cron task. Find the image
here: https://hub.docker.com/repository/docker/martlark/pg_dump

## Usage

Import a PostgreSQL database into this container and mount a volume to the containers `/dump` folder. 
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
| `COMMAND`                | `None`       | Optional   | `dump-cron` | Options: `dump` dumps the database and exit, `dump-cron` creates a cron job and runs    |
| `POSTGRES_PASSWORD_FILE` | `None`       | Recommended | `None`               | Location of the password file. Overrides `POSTGRES_PASSWORD` and `PGPASSWORD` |
| `S3_ACCESS_KEY`          | `None`       | Required for S3 sync   | `None` | Access key to connect to S3. Example: `AKIAIOSFODNN7EXAMPLE`                     |
| `S3_SECRET_KEY`          | `None`       | Required for S3 sync   | `None` | Secret key to connect to S3. Example: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `S3_BUCKET_PATH` | `None` | Required for S3 sync  | `None`   | Full path to the bucket and directory to store the dumps. Example: `s3://my-bucket/db-dumps/` |
| `S3_HOSTNAME`    | `None` | Optional  | `s3.amazonaws.com`            | Configurable for a non-AWS S3 implementation. Example: `mys3server.local`            |
| `S3_HOST_BUCKET` | `None` | Optional  | `%(bucket)s.s3.amazonaws.com` | Configurable for a non-AWS S3 implementation. Example: `mys3server.local/%(bucket)`  |
| `S3_SSL_OPTION`  | `None` | Optional  | `--ssl`                       | Options: `--ssl` to enable SSL, `--no-ssl` to disable SSL                            |

## Optional Controls

By default, this container executes as the postgres user. Using a non-root user for your container
is always a safer route and should be one of your first modifications. The POSTGRES_PASSWORD field can 
either be set via environment variable or via docker secrets. Again, for security reasons, it is
always recommended to use docker secrets for security concerns. If using the docker secrets, set the
POSTGRES_PASSWORD_FILE field, warning this overrides POSTGRES_PASSWORD and PGPASSWORD. An example secrets 
file can be found below in the docker-compose area. The default for PGHOST is dependant on if RUN_DOUBLE 
is set; if RUN_DOUBLE is "true" than "db" is the default, if RUN_DOUBLE is "false" than "localhost" is
the default. PGPORT is the exposed port in the container, so it is recommended not to change this.

Synchronization to S3 requires setting `S3_ACCESS_KEY`, `S3_SECRET_KEY`, and `S3_BUCKET_PATH`. The other `S3_` variables are only required if you are connecting to a non-AWS S3 implementation.

## Docker Compose

Always run as separate services with `pgdump` running alongside the main Postgres database service.

### Example of running with separate services.

```yaml
version: "3.9"
services:
  database:
    image: postgres:12.14
    volumes:
      - ./persistent/data:/var/lib/postgresql/data
    environment:
      - POSTGRES_PASSWORD=SumPassw0rdHere
      - POSTGRES_DB=postgres
    restart: unless-stopped

  postgres-backup:
    image: martlark/pg_dump:12.14
    container_name: postgres-backup
    links:
      - database:db # Maps as "db"
    environment:
      - PGPASSWORD=SumPassw0rdHere
      - CRON_SCHEDULE=0 3 * * * # Every day at 3am
      - RETAIN_COUNT=4 # Keep this number of backups
    volumes:
      - ./persistent/data:/dump
```

### Example asswords file

```text
POSTGRES_PASSWORD=SumPassw0rdHere
```

Tagged versions
===============

Versions available on docker hub are:

    11.19 12.14 13.10 14.7 15.2
	
    latest is 15.2

