#!/bin/bash
# dump and delete old backups
# note: executes as postgres

PREFIX=${PREFIX:-dump}
PGUSER=${PGUSER:-postgres}
POSTGRES_DB=${POSTGRES_DB:-postgres}
PGHOST=${PGHOST:-localhost}
PGPORT=${PGPORT:-5432}
PGDUMP=${PGDUMP:-'/dump'}
export PGPASSWORD=${PGPASSWORD:-$POSTGRES_PASSWORD}

DATE=$(date +%Y%m%d_%H%M%S)
FILE="$PGDUMP/$PREFIX-$POSTGRES_DB-$DATE.sql"

mkdir -p "${PGDUMP}"

echo "--------"
echo "Job started: $(date). Dumping to ${FILE}"

pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -f "$FILE" -d "$POSTGRES_DB"
gzip "$FILE"

if [[ -n "${RETAIN_COUNT}" ]]; then
    file_count=1
    for file_name in $(ls -t $PGDUMP/*.gz); do
        if (( ${file_count} > ${RETAIN_COUNT} )); then
            echo "Removing older dump file: ${file_name}"
            rm "${file_name}"
        fi
        ((file_count++))
    done
else
    echo "No RETAIN_COUNT! Take care with disk space."
fi

# Sync dumps with S3

# S3 Options

S3_SYNC_OPTION=${S3_SYNC_OPTION:---delete-after --delete-removed}

if [[ -n "${S3_ACCESS_KEY}" && -n "${S3_SECRET_KEY}" && -n "${S3_BUCKET_PATH}" ]]; then

    TRIMMED_BUCKET_PATH=$(echo "${S3_BUCKET_PATH}" | sed 's:/*$::')
    echo "Syncing with S3: ${PGDUMP}/ -> ${TRIMMED_BUCKET_PATH}/"
    s3cmd --access_key "${S3_ACCESS_KEY}" --secret_key "${S3_SECRET_KEY}" \
          --host "${S3_HOSTNAME}" --host-bucket "${S3_HOST_BUCKET}" \
          --exclude "dump-log" \
          ${S3_SYNC_OPTION} "${S3_SSL_OPTION}" \
          sync "${PGDUMP}/" "${TRIMMED_BUCKET_PATH}/"

fi

echo "Job finished: $(date)"
