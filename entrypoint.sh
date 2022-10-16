#!/bin/bash
# entrypoint.sh
set -e

if [[ -z $COMMAND ]];
then
   COMMAND=${1:-dump-cron}
fi

CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}
PREFIX=${PREFIX:-dump}
PGUSER=${PGUSER:-postgres}
POSTGRES_DB=${POSTGRES_DB:-postgres}
PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGDUMP=${PGDUMP:-'/dump'}
POSTGRES_PASSWORD_FILE=${POSTGRES_PASSWORD_FILE:-'/run/secrets/db_password'}

if [[ -n ${PG_LOG} ]];
then
   echo "COMMAND: ${COMMAND}"
   echo "CRON_SCHEDULE: ${CRON_SCHEDULE}"
   echo "PREFIX: ${PREFIX}"
   echo "PGUSER: ${PGUSER}"
   echo "POSTGRES_DB: ${POSTGRES_DB}"
   echo "PGHOST: ${PGHOST}"
   echo "PGPORT: ${PGPORT}"
   echo "PGDUMP: ${PGDUMP}"
   echo "POSTGRES_PASSWORD_FILE: ${POSTGRES_PASSWORD_FILE}"
fi

if [[ -f /run/secrets/db_password ]];
then
   source /run/secrets/db_password
else
   echo "ERROR: No password file found!"
   echo "It is suggested that a docker secrets file is used for security concerns."
   echo "If not, ensure that POSTGRES_PASSWORD is set."
fi

if [[ "${COMMAND}" == 'dump' ]]; then
    /usr/local/bin/docker-entrypoint.sh postgres &
    SLEEPTIME=5
    echo "Sleeping ${SLEEPTIME} seconds to allow database to stand up..."
    sleep ${SLEEPTIME}
    exec /dump.sh
elif [[ "${COMMAND}" == 'dump-cron' ]]; then

    if [[ -z ${LOGFIFO} ]];
    then
      LOGFIFO=${PGDUMP}/cron.fifo
    fi

    if [[ -n ${PG_LOG} ]];
    then
        echo "LOGFIFO: ${LOGFIFO}"
    fi
    if [[ ! -e "${LOGFIFO}" ]]; then
        mkfifo "${LOGFIFO}"
    fi
    CRON_ENV="PREFIX='$PREFIX'\nPGUSER='${PGUSER}'\nPOSTGRES_DB='${POSTGRES_DB}'\nPGHOST='${PGHOST}'\nPGPORT='${PGPORT}'\nPGDUMP='${PGDUMP}'"
    if [[ -n "${POSTGRES_PASSWORD}" ]]; then
        CRON_ENV="$CRON_ENV\nPOSTGRES_PASSWORD='${POSTGRES_PASSWORD}'"
    fi

    if [[ ! -z "${RETAIN_COUNT}" ]]; then
    	CRON_ENV="$CRON_ENV\nRETAIN_COUNT='${RETAIN_COUNT}'"
    fi

    echo -e "$CRON_ENV\n$CRON_SCHEDULE /dump.sh > $LOGFIFO 2>&1" | crontab -
    # crontab -l
    cron
    /usr/local/bin/docker-entrypoint.sh postgres
else
    echo "Unknown command: $COMMAND"
    echo "Available commands: dump, dump-cron"
    exit 1
fi
