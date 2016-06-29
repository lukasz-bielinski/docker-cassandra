FROM oberthur/docker-ubuntu-java:jdk8_8.65.17

MAINTAINER Dawid Malinowski <d.malinowski@oberthur.com>

ENV JVM_OPTS="-server -Dcassandra.compaction.priority=1 -XX:+UseCompressedOops -XX:+AlwaysPreTouch" \
  CASSANDRA_VERSION=2.1.11 \
  DATASTAX_AGENT_VERSION=5.2.2

RUN echo "deb http://debian.datastax.com/community stable main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list \
    && curl -L http://debian.datastax.com/debian/repo_key | apt-key add - \
    && apt-get update && apt-get install -y --force-yes sudo sysstat libjna-java dsc21=${CASSANDRA_VERSION}* cassandra=${CASSANDRA_VERSION}* cassandra-tools=${CASSANDRA_VERSION}* datastax-agent=${DATASTAX_AGENT_VERSION}* \
    && sed -i -e "s/^rpc_address: localhost/# rpc_address: localhost/" /etc/cassandra/cassandra.yaml \
    && sed -i -e "s/# rpc_interface: eth1/rpc_interface: eth0/" /etc/cassandra/cassandra.yaml \
    && sed -i -e 's/<appender-ref ref="FILE" \/>/\r/' /etc/cassandra/logback.xml \
    && mkdir /root/.cassandra \
    && echo "[connection]\nclient_timeout=120" >> /root/.cassandra/cqlshrc \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean 

ADD start-cassandra.sh /bin/start-cassandra.sh

EXPOSE 7000 7001 7199 9160 9042 61621 61622

CMD ["sh", "/bin/start-cassandra.sh"]
