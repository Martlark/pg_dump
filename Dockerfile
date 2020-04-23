FROM postgres:9
MAINTAINER rowe.andrew.d@gmail.com

RUN apt-get update && \
    apt-get install -y cron && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ADD *.sh /
RUN chmod +x /*.sh

VOLUME /dump

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dump-cron"]
