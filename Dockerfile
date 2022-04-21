ARG POSTGRES_VERSION=12.1
FROM postgres:${POSTGRES_VERSION}
MAINTAINER rowe.andrew.d@gmail.com

RUN apt-get update && \
    apt-get install -y cron && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD *.sh /
RUN chmod +x /*.sh

VOLUME /dump

ENTRYPOINT ["sh", "/entrypoint.sh"]
CMD ["dump-cron"]
