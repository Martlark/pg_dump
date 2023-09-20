ARG POSTGRES_VERSION=12.16
FROM postgres:${POSTGRES_VERSION}-bullseye
LABEL org.opencontainers.image.authors="rowe.andrew.d@gmail.com"

RUN \
apt-get update && \
apt-get install -y cron  && \
apt-get install -y s3cmd  && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

EXPOSE 5432
ENV PGDATA="/data"
ENV PGDUMP="/dump"
ENV PGUSER=postgres

# S3 defaults
ENV S3_HOSTNAME="s3.amazonaws.com"
ENV S3_HOST_BUCKET="%(bucket)s.s3.amazonaws.com"
ENV S3_SSL_OPTION="--ssl"

COPY --chown=${PGUSER}:${PGUSER} \
   [ "dump.sh", \
     "entrypoint.sh", \
     "/" ]

USER root

RUN \
chmod 755 dump.sh && \
chmod 755 entrypoint.sh && \
chmod gu+rw /var/run && \
chmod gu+s /usr/sbin/cron && \
mkdir ${PGDUMP} && \
chown ${PGUSER}:${PGUSER} ${PGDUMP} && \
mkdir ${PGDATA} && \
chown ${PGUSER}:${PGUSER} ${PGDATA}

VOLUME [ "${PGDUMP}", "${PGDATA}" ]

USER ${PGUSER}

ENTRYPOINT ["bash", "-x", "/entrypoint.sh"]
CMD ["dump-cron"]
