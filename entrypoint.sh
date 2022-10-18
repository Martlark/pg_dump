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
PGPORT=${PGPORT:-5432}
PGDUMP=${PGDUMP:-'/dump'}
RUN_DOUBLE=${RUN_DOUBLE:-"true"}

if [[ ${RUN_DOUBLE} == "true" ]];
then
   PGHOST=${PGHOST:-db}
else
   PGHOST=${PGHOST:-localhost}
fi

if [[ -n ${PGDB} ]];
then
   POSTGRES_DB=${PGDB:-postgres}
else 
   POSTGRES_DB=${POSTGRES_DB:-postgres}
fi

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

   if [[ -n ${POSTGRES_PASSWORD_FILE} ]];
   then
      echo "POSTGRES_PASSWORD_FILE: ${POSTGRES_PASSWORD_FILE}"
   fi
fi

if [[ -f ${POSTGRES_PASSWORD_FILE} ]];
then
   source ${POSTGRES_PASSWORD_FILE}
else
   echo "WARN: No password file found!"
   echo "It is suggested that a docker secrets file is used for security concerns."

   if [[ -n ${PGPASSWORD} ]];
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

    if [[ "${RUN_DOUBLE}" == "true" ]];
    then
      tail -f ${LOGFIFO} # Run in two containers
    else
      /usr/local/bin/docker-entrypoint.sh postgres # Run in one container
    fi
else
    echo "Unknown command: $COMMAND"
    echo "Available commands: dump, dump-cron"
    exit 1
fi
