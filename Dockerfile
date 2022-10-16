ARG POSTGRES_VERSION=12.1
FROM postgres:${POSTGRES_VERSION}
LABEL org.opencontainers.image.authors="rowe.andrew.d@gmail.com"

EXPOSE 5432
ENV PGUSER=postgres
ENV PGDATA="/data"

COPY --chown=${PGUSER}:${PGUSER} \
   [ "dump.sh", \
     "entrypoint.sh", \
     "/" ]

USER root

VOLUME [ "/dump", "/data" ]

RUN \
apt-get update && \
apt-get install -y cron  && \
apt-get clean && \
rm -rf /var/lib/apt/lists/* && \
chmod 755 dump.sh && \
chmod 755 entrypoint.sh && \
chmod gu+rw /var/run && \
chmod gu+s /usr/sbin/cron && \
mkdir /dump && \
chown ${PGUSER}:${PGUSER} /dump && \
mkdir /data && \
chown ${PGUSER}:${PGUSER} /data

USER ${PGUSER}

ENTRYPOINT ["bash", "/entrypoint.sh"]
CMD ["dump-cron"]
