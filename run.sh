#!/bin/bash
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

BENCH_CASSANDRA_EXISTS=`docker inspect --format="{{ .Id }}" bench-cassandra-php-cassandra 2> /dev/null`

if ! [ -z "$BENCH_CASSANDRA_EXISTS" ]
then
  docker kill bench-cassandra-php-cassandra
  docker rm bench-cassandra-php-cassandra
fi

docker run \
  --name bench-cassandra-php-cassandra \
  -d \
  spotify/cassandra

docker run \
-it \
--link bench-cassandra-php-cassandra:cassandra \
-v $DIR/src:/root/src \
bmichalski/bench-cassandra-php \
bash #-c "su - r"
