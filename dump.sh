#!/bin/bash

set -e

PREFIX=${PREFIX:-dump}
PGUSER=${PGUSER:-postgres}
POSTGRES_DB=${POSTGRES_DB:-postgres}
PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGDUMP=${PGDUMP:-'/dump'}

DATE=$(date +%Y%m%d_%H%M%S)
FILE="$PGDUMP/$PREFIX-$POSTGRES_DB-$DATE.sql"

echo "Job started: $(date). Dumping to ${FILE}"

pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -f "$FILE" -d "$POSTGRES_DB"
gzip "$FILE"

if [[ -n "${RETAIN_COUNT}" ]]; then
    file_count=1
    for file_name in $(ls -t $PGDUMP/*.gz); do
        if [[ ${file_count} > ${RETAIN_COUNT} ]]; then
            echo "Removing older dump file: ${file_name}"
            rm "${file_name}"
        fi
        ((file_count++))
    done
else
    echo "No RETAIN_COUNT! take care with disk space."
fi

echo "Job finished: $(date)"
