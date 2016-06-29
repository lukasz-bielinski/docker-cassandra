#!/bin/bash

# DATASTAX AGENT
if [ "$OPSCENTER_IP" != "" ]; then
  echo "stomp_interface: ${$OPSCENTER_IP}" > /var/lib/datastax-agent/conf/address.yaml
fi

if [ "$OPSCENTER_USE_SSL" != "" ]; then
  echo "use_ssl: ${OPSCENTER_USE_SSL}" >> /var/lib/datastax-agent/conf/address.yaml
fi

if [ "$BROADCAST_ADDRESS" != "" ]; then
  echo "local_interface: ${BROADCAST_ADDRESS}" >> /var/lib/datastax-agent/conf/address.yaml
fi

# CASSANDRA
if [ "$DC_NAME" != "" ] && [ "$RACK_NAME" != "" ]; then
  sed -i -e "s/dc=DC1/dc=${DC_NAME}/" /etc/cassandra/cassandra-rackdc.properties
  sed -i -e "s/rack=RAC1/rack=${DC_NAME}/" /etc/cassandra/cassandra-rackdc.properties
  sed -i -e 's/^# prefer_local=true/prefer_local=true/' /etc/cassandra/cassandra-rackdc.properties
fi

if [ "$SNITCH" != "" ]; then
  sed -i -e "s/endpoint_snitch: SimpleSnitch/endpoint_snitch: $SNITCH/" /etc/cassandra/cassandra.yaml
fi

if [ "$CLUSTER_NAME" != "" ]; then
  sed -i -e "s/cluster_name: 'Test Cluster'/cluster_name: '${CLUSTER_NAME}'/" /etc/cassandra/cassandra.yaml
fi

if [ "$AUTHENTICATOR" != "" ]; then
  sed -i -e "s/authenticator: AllowAllAuthenticator/authenticator: $AUTHENTICATOR/" /etc/cassandra/cassandra.yaml
fi

if [ "$AUTHORIZER" != "" ]; then
  sed -i -e "s/authorizer: AllowAllAuthorizer/authorizer: $AUTHORIZER/" /etc/cassandra/cassandra.yaml
fi

for SEED in $( env |grep SEED_ |sort |awk 'match($0, /SEED_[0-9]+/) { print substr( $0, RSTART, RLENGTH )}' |uniq )
do
  CURRENT=$( env |grep ${SEED} |sed 's/^[^=]*=//' )
  SEEDS_LIST="$SEEDS_LIST $CURRENT"
done

if [ "$SEEDS_LIST" != "" ]; then
  SEEDS=$( echo ${SEEDS_LIST} | tr ' ' ', ' )
  sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: ${SEEDS}\"/" /etc/cassandra/cassandra.yaml
fi

if [ "$BROADCAST_ADDRESS" != "" ]; then
  sed -i -e "s/# broadcast_address: 1.2.3.4/broadcast_address: ${BROADCAST_ADDRESS}/" /etc/cassandra/cassandra.yaml
fi

if [ "$BROADCAST_RPC" != "" ]; then
  sed -i -e "s/# broadcast_rpc_address: 1.2.3.4/broadcast_rpc_address: ${BROADCAST_RPC}/" /etc/cassandra/cassandra.yaml
fi

sed -i -e "s/listen_address: localhost/#listen_address: localhost/" /etc/cassandra/cassandra.yaml
sed -i -e "s/# listen_interface: eth0/listen_interface: eth0/" /etc/cassandra/cassandra.yaml
sed -i -e "s/# rpc_address: localhost/rpc_address: 0.0.0.0/" /etc/cassandra/cassandra.yaml
sed -i -e "s/rpc_interface: eth0/# rpc_interface: eth1/" /etc/cassandra/cassandra.yaml

if [ "$JMX_HOSTNAME" != "" ]; then
  sed -i -e "s/# JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=<public name>\"/JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=\$JMX_HOSTNAME\"/" /etc/cassandra/cassandra-env.sh
  sed -i -e "s/JVM_OPTS=\"\$JVM_OPTS -Dcom.sun.management.jmxremote.password.file=\/etc\/cassandra\/jmxremote.password\"/JVM_OPTS=\"\$JVM_OPTS -Dcom.sun.management.jmxremote.password.file=\/etc\/cassandra\/jmx\/jmxremote.password\"/" /etc/cassandra/cassandra-env.sh
fi

sed -i -e "s|<appender-ref ref=\"STDOUT\" \/>|<appender-ref ref=\"FILE\" \/>|" /etc/cassandra/logback.xml

(sleep 10 && service datastax-agent start &)
exec /usr/sbin/cassandra -f -p /var/run/cassandra/cassandra.pid
