ARG POSTGRES_VERSION=12.1
FROM postgres:${POSTGRES_VERSION}
LABEL org.opencontainers.image.authors="rowe.andrew.d@gmail.com"

RUN \
apt-get update && \
apt-get install -y cron  && \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

EXPOSE 5432
ENV PGDATA="/data"
ENV PGDUMP="/dump"
ENV PGUSER=postgres

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

VOLUME [ ${PGDUMP}, ${PGDATA} ]

USER ${PGUSER}

ENTRYPOINT ["bash", "/entrypoint.sh"]
CMD ["dump-cron"]
