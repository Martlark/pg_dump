#!/bin/bash
# entrypoint.sh
set -e

COMMAND=${1:-dump-cron}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}
PREFIX=${PREFIX:-dump}
PGUSER=${PGUSER:-postgres}
PGDB=${PGDB:-postgres}
PGHOST=${PGHOST:-db}
PGPORT=${PGPORT:-5432}


if [[ "${COMMAND}" == 'dump' ]]; then
    exec /dump.sh
elif [[ "${COMMAND}" == 'dump-cron' ]]; then
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "${LOGFIFO}" ]]; then
        mkfifo "${LOGFIFO}"
    fi
    CRON_ENV="PREFIX='$PREFIX'\nPGUSER='${PGUSER}'\nPGDB='${PGDB}'\nPGHOST='${PGHOST}'\nPGPORT='${PGPORT}'"
    if [[ -n "${PGPASSWORD}" ]]; then
        CRON_ENV="$CRON_ENV\nPGPASSWORD='${PGPASSWORD}'"
    fi

    if [[ ! -z "${RETAIN_COUNT}" ]]; then
    	CRON_ENV="$CRON_ENV\nRETAIN_COUNT='${RETAIN_COUNT}'"
    fi

    echo -e "$CRON_ENV\n$CRON_SCHEDULE /dump.sh > $LOGFIFO 2>&1" | crontab -
    # crontab -l
    cron
    tail -f "$LOGFIFO"
else
    echo "Unknown command $COMMAND"
    echo "Available commands: dump, dump-cron"
    exit 1
fi
