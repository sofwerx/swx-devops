#!/bin/bash
export CASSANDRA_RPC_ADDRESS=$(ip addr show | grep 'inet 192.168.1' | cut -d/ -f1 | awk '{print $2}')

cat <<EOF > /tmp/grr.properties
# conf/gremlin-server/janusgraph-cql-es-server.properties
gremlin.graph=org.janusgraph.core.JanusGraphFactory

# JanusGraph configuration sample: Cassandra & Elasticsearch over sockets

# This file connects to Cassandra and Elasticsearch services running
# on localhost over the CQL API and the Elasticsearch native
# "Transport" API on their respective default ports.  The Cassandra
# and Elasticsearch services must already be running before starting
# JanusGraph with this file.

# The primary persistence provider used by JanusGraph.  This is required.  It
# should be set one of JanusGraph's built-in shorthand names for its standard
# storage backends or to the full package and classname of a custom/third-party
# StoreManager implementation.
#
# Default:    (no default value)
# Data Type:  String
# Mutability: LOCAL
storage.backend=cql

# The hostname or comma-separated list of hostnames of storage backend
# servers.  This is only applicable to some storage backends, such as
# cassandra and hbase.
#
# Default:    127.0.0.1
# Data Type:  class java.lang.String[]
# Mutability: LOCAL
storage.hostname=${CASSANDRA_RPC_ADDRESS}

# The name of JanusGraph's keyspace.  It will be created if it does not
# exist.
#
# Default:    janusgraph
# Data Type:  String
# Mutability: LOCAL
storage.cql.keyspace=janusgraph

storage.cql.astyanax.cluster-name=${CASSANDRA_CLUSTER_NAME}

# Whether to enable JanusGraph's database-level cache, which is shared across
# all transactions. Enabling this option speeds up traversals by holding
# hot graph elements in memory, but also increases the likelihood of
# reading stale data.  Disabling it forces each transaction to
# independently fetch graph elements from storage before reading/writing
# them.
#
# Default:    false
# Data Type:  Boolean
# Mutability: MASKABLE
cache.db-cache = true

# How long, in milliseconds, database-level cache will keep entries after
# flushing them.  This option is only useful on distributed storage
# backends that are capable of acknowledging writes without necessarily
# making them immediately visible.
#
# Default:    50
# Data Type:  Integer
# Mutability: GLOBAL_OFFLINE
#
# Settings with mutability GLOBAL_OFFLINE are centrally managed in JanusGraph's
# storage backend.  After starting the database for the first time, this
# file's copy of this setting is ignored.  Use JanusGraph's Management System
# to read or modify this value after bootstrapping.
cache.db-cache-clean-wait = 20

# Default expiration time, in milliseconds, for entries in the
# database-level cache. Entries are evicted when they reach this age even
# if the cache has room to spare. Set to 0 to disable expiration (cache
# entries live forever or until memory pressure triggers eviction when set
# to 0).
#
# Default:    10000
# Data Type:  Long
# Mutability: GLOBAL_OFFLINE
#
# Settings with mutability GLOBAL_OFFLINE are centrally managed in JanusGraph's
# storage backend.  After starting the database for the first time, this
# file's copy of this setting is ignored.  Use JanusGraph's Management System
# to read or modify this value after bootstrapping.
cache.db-cache-time = 180000

# Size of JanusGraph's database level cache.  Values between 0 and 1 are
# interpreted as a percentage of VM heap, while larger values are
# interpreted as an absolute size in bytes.
#
# Default:    0.3
# Data Type:  Double
# Mutability: MASKABLE
cache.db-cache-size = 0.25

# Connect to an already-running ES instance on localhost

# The indexing backend used to extend and optimize JanusGraph's query
# functionality. This setting is optional.  JanusGraph can use multiple
# heterogeneous index backends.  Hence, this option can appear more than
# once, so long as the user-defined name between "index" and "backend" is
# unique among appearances.Similar to the storage backend, this should be
# set to one of JanusGraph's built-in shorthand names for its standard index
# backends (shorthands: lucene, elasticsearch, es, solr) or to the full
# package and classname of a custom/third-party IndexProvider
# implementation.
#
# Default:    elasticsearch
# Data Type:  String
# Mutability: GLOBAL_OFFLINE
#
# Settings with mutability GLOBAL_OFFLINE are centrally managed in JanusGraph's
# storage backend.  After starting the database for the first time, this
# file's copy of this setting is ignored.  Use JanusGraph's Management System
# to read or modify this value after bootstrapping.
index.search.backend=elasticsearch

# The hostname or comma-separated list of hostnames of index backend
# servers.  This is only applicable to some index backends, such as
# elasticsearch and solr.
#
# Default:    127.0.0.1
# Data Type:  class java.lang.String[]
# Mutability: MASKABLE
index.search.hostname=${ELASTIC_CLUSTER_IP}
index.search.port=${ELASTIC_CLUSTER_PORT:-9300}
index.search.elasticsearch.cluster-name=${ELASTIC_CLUSTER_NAME}

# The Elasticsearch node.client option is set to this boolean value, and
# the Elasticsearch node.data option is set to the negation of this value.
# True creates a thin client which holds no data.  False creates a regular
# Elasticsearch cluster node that may store data.
#
# Default:    true
# Data Type:  Boolean
# Mutability: GLOBAL_OFFLINE
#
# Settings with mutability GLOBAL_OFFLINE are centrally managed in JanusGraph's
# storage backend.  After starting the database for the first time, this
# file's copy of this setting is ignored.  Use JanusGraph's Management System
# to read or modify this value after bootstrapping.
index.search.elasticsearch.client-only=true

# Or start ES inside the JanusGraph JVM
#index.search.backend=elasticsearch
#index.search.directory=db/es
#index.search.elasticsearch.client-only=false
#index.search.elasticsearch.local-mode=true
EOF

#cat <<EOF > conf/gremlin-server/gremlin-server.yaml
#host: 0.0.0.0
#port: 8182
#scriptEvaluationTimeout: 30000
#channelizer: org.apache.tinkerpop.gremlin.server.channel.WebSocketChannelizer
#graphs: {
#  graph: conf/gremlin-server/janusgraph-cql-es-server.properties
#}
#scriptEngines: {
#  gremlin-groovy: {
#    plugins: { org.janusgraph.graphdb.tinkerpop.plugin.JanusGraphGremlinPlugin: {},
#               org.apache.tinkerpop.gremlin.server.jsr223.GremlinServerGremlinPlugin: {},
#               org.apache.tinkerpop.gremlin.tinkergraph.jsr223.TinkerGraphGremlinPlugin: {},
#               org.apache.tinkerpop.gremlin.jsr223.ImportGremlinPlugin: {classImports: [java.lang.Math], methodImports: [java.lang.Math#*]},
#               org.apache.tinkerpop.gremlin.jsr223.ScriptFileGremlinPlugin: {files: [scripts/empty-sample.groovy]}}}}
#serializers:
#  - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV3d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] }}
#  - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV3d0, config: { serializeResultToString: true }}
#  - { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerV3d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] }}
#  # Older serialization versions for backwards compatibility:
#  - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV1d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] }}
#  - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoLiteMessageSerializerV1d0, config: {ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] }}
#  - { className: org.apache.tinkerpop.gremlin.driver.ser.GryoMessageSerializerV1d0, config: { serializeResultToString: true }}
#  - { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerGremlinV2d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistry] }}
#  - { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerGremlinV1d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistryV1d0] }}
#  - { className: org.apache.tinkerpop.gremlin.driver.ser.GraphSONMessageSerializerV1d0, config: { ioRegistries: [org.janusgraph.graphdb.tinkerpop.JanusGraphIoRegistryV1d0] }}
#processors:
#  - { className: org.apache.tinkerpop.gremlin.server.op.session.SessionOpProcessor, config: { sessionTimeout: 28800000 }}
#  - { className: org.apache.tinkerpop.gremlin.server.op.traversal.TraversalOpProcessor, config: { cacheExpirationTime: 600000, cacheMaxSize: 1000 }}
#metrics: {
#  consoleReporter: {enabled: true, interval: 180000},
#  csvReporter: {enabled: true, interval: 180000, fileName: /tmp/gremlin-server-metrics.csv},
#  jmxReporter: {enabled: true},
#  slf4jReporter: {enabled: true, interval: 180000},
#  gangliaReporter: {enabled: false, interval: 180000, addressingMode: MULTICAST},
#  graphiteReporter: {enabled: false, interval: 180000}}
#maxInitialLineLength: 4096
#maxHeaderSize: 8192
#maxChunkSize: 8192
#maxContentLength: 65536
#maxAccumulationBufferComponents: 1024
#resultIterationBatchSize: 64
#writeBufferLowWaterMark: 32768
#writeBufferHighWaterMark: 65536
#EOF
#
#cat <<EOF > conf/gremlin-server/log4j-server.properties
## A1 is a FileAppender.
#log4j.appender.A1=org.apache.log4j.FileAppender
#log4j.appender.A1.File=$\{janusgraph.logdir\}/gremlin-server.log
#log4j.appender.A1.Threshold=INFO
## A1 uses PatternLayout.
#log4j.appender.A1.layout=org.apache.log4j.PatternLayout
#log4j.appender.A1.layout.ConversionPattern=%-4r [%t] %-5p %c %x - %m%n
#
## A2 is a ConsoleAppender.
#log4j.appender.A2=org.apache.log4j.ConsoleAppender
#log4j.appender.A2.Threshold=INFO
## A2 uses PatternLayout.
#log4j.appender.A2.layout=org.apache.log4j.PatternLayout
#log4j.appender.A2.layout.ConversionPattern=%-4r [%t] %-5p %c %x - %m%n
#
## Set both appenders (A1 and A2) on the root logger.
#log4j.rootLogger=INFO, A1, A2
#EOF

exec /home/janusgraph/janusgraph/bin/gremlin-server.sh $@
