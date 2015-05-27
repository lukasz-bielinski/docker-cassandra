FROM oberthur/docker-ubuntu-java:jdk8_8.45.14

MAINTAINER Dawid Malinowski <d.malinowski@oberthur.com>

ENV JVM_OPTS -server -Dcassandra.compaction.priority=1 -XX:+UseCompressedOops
ENV OPSCENTER_VERSION 5.1.1

RUN echo "deb http://debian.datastax.com/community stable main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list && \
	curl -L http://debian.datastax.com/debian/repo_key | apt-key add - && \
	apt-get update && apt-get install -y opscenter=${OPSCENTER_VERSION}* && \
	sed -i -e "s/^interface.*/interface = 0.0.0.0/" /etc/opscenter/opscenterd.conf && \
	echo "" > /var/log/opscenter/opscenterd.log

RUN rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    echo "echo Starting OpsCenter on $IP...\nservice opscenterd start\ntail -f /var/log/opscenter/opscenterd.log" > /bin/start.sh

EXPOSE 8888 61619 61620

CMD ["sh", "/bin/start.sh"]
