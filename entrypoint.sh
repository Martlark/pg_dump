#!/bin/bash
# entrypoint.sh
# note: executes as postgres
set -e
PGDUMP=${PGDUMP:-'/dump'}
echo "Starting pg_dump" | tee "${PGDUMP}/dump-log"
if [[ -z $COMMAND ]];
then
   COMMAND=${1:-dump-cron}
fi

CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}
PREFIX=${PREFIX:-dump}
PGUSER=${PGUSER:-postgres}
PGPORT=${PGPORT:-5432}

if [[ -n "${PGDB}" ]];
then
   POSTGRES_DB=${PGDB:-postgres}
else 
   POSTGRES_DB=${POSTGRES_DB:-postgres}
fi

if [[ -f ${POSTGRES_PASSWORD_FILE} ]];
then
   source ${POSTGRES_PASSWORD_FILE}
else
   echo "WARN: No password file found!"
   echo "It is suggested that a docker secrets file is used for security concerns."

   if [[ -n "${PGPASSWORD}" ]];
   then
      POSTGRES_PASSWORD=${PGPASSWORD}
   elif [[ -z ${POSTGRES_PASSWORD} ]];
   then
      echo "ERROR: No POSTGRES_PASSWORD set!"
      exit 1
   fi
fi

if [[ "${COMMAND}" == 'dump' ]]; then
    /usr/local/bin/docker-entrypoint.sh postgres &
    SLEEPTIME=5
    echo "Sleeping ${SLEEPTIME} seconds to allow database to stand up..."
    sleep ${SLEEPTIME}
    exec /dump.sh
elif [[ "${COMMAND}" == 'dump-cron' ]]; then

    CRON_ENV="PREFIX='$PREFIX'\nPGUSER='${PGUSER}'\nPOSTGRES_DB='${POSTGRES_DB}'\nPGHOST='${PGHOST}'\nPGPORT='${PGPORT}'\nPGDUMP='${PGDUMP}'"
    if [[ -n "${POSTGRES_PASSWORD}" ]]; then
        CRON_ENV="$CRON_ENV\nPOSTGRES_PASSWORD='${POSTGRES_PASSWORD}'"
    fi

    if [[ ! -z "${RETAIN_COUNT}" ]]; then
        CRON_ENV="$CRON_ENV\nRETAIN_COUNT=${RETAIN_COUNT}"
    fi

    # S3 settings
    CRON_ENV="$CRON_ENV\nS3_HOSTNAME='${S3_HOSTNAME}'"
    CRON_ENV="$CRON_ENV\nS3_HOST_BUCKET='${S3_HOST_BUCKET}'"
    CRON_ENV="$CRON_ENV\nS3_SSL_OPTION='${S3_SSL_OPTION}'"
    if [[ ! -z "${S3_ACCESS_KEY}" ]]; then
        CRON_ENV="$CRON_ENV\nS3_ACCESS_KEY='${S3_ACCESS_KEY}'"
    fi

    if [[ ! -z "${S3_SECRET_KEY}" ]]; then
        CRON_ENV="$CRON_ENV\nS3_SECRET_KEY='${S3_SECRET_KEY}'"
    fi

    if [[ ! -z "${S3_BUCKET_PATH}" ]]; then
        CRON_ENV="$CRON_ENV\nS3_BUCKET_PATH='${S3_BUCKET_PATH}'"
    fi

    echo -e "$CRON_ENV\n$CRON_SCHEDULE" "/dump.sh >> ${PGDUMP}/dump-log 2>&1" | crontab -
#    crontab -l
    cron
    tail -F "${PGDUMP}/dump-log"
else
    echo "Unknown command: $COMMAND"
    echo "Available commands: dump, dump-cron"
    exit 1
fi
