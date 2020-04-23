#!/bin/bash

set -e

PREFIX=${PREFIX:-dump}
PGUSER=${PGUSER:-postgres}
PGDB=${PGDB:-postgres}
PGHOST=${PGHOST:-db}
PGPORT=${PGPORT:-5432}

DATE=$(date +%Y%m%d_%H%M%S)
FILE="/dump/$PREFIX-$PGDB-$DATE.sql"

echo "Job started: $(date). Dumping to ${FILE}"

pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -f "$FILE" -d "$PGDB"
gzip "$FILE"

if [[ ! -z "${RETAIN_COUNT}" ]]; then
    file_count=1
    for file_name in $(ls -t /dump/*.gz); do
        if [[ ${file_count} > ${RETAIN_COUNT} ]]; then
            echo "Removing older dump file: ${file_name}"
            rm ${file_name}
        fi
        ((file_count++))
    done
else
    echo "No RETAIN_COUNT! take care with disk space."
fi

echo "Job finished: $(date)"
