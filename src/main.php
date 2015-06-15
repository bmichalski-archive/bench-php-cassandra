<?php

$cluster = Cassandra::cluster()
    ->withPersistentSessions()
    ->withContactPoints('cassandra')
    ->build();

$session = $cluster->connect();

$dropKeyspace = new Cassandra\SimpleStatement('DROP KEYSPACE test');

$createKeyspace = new Cassandra\SimpleStatement(<<<EOD
CREATE KEYSPACE test
WITH replication = {
  'class': 'SimpleStrategy',
  'replication_factor': 1
}
EOD
);

$dropTable = new Cassandra\SimpleStatement('DROP TABLE test');

$createTable = new Cassandra\SimpleStatement(<<<EOD
CREATE TABLE test (
  id INT,
  value DOUBLE,
  PRIMARY KEY (id)
)
EOD
);

try {
    $session->execute($dropKeyspace);
} catch (Exception $ex) {
}

$session->execute($createKeyspace);
$session->execute(new Cassandra\SimpleStatement('USE test'));
$session->execute($createTable);

$statement = $session->prepare('INSERT INTO test (id, value) VALUES (?, ?)');

$begin = time();

$futures = [];

$k = 1;

for ($i = 0; $i < 1; $i += 1) {
    $batch = new Cassandra\BatchStatement();

    for ($j = 0; $j < 10000; $j += 1) {
        $k += 1;

        $statement = $session->prepare('INSERT INTO test (id, value) VALUES (?, ?)');
        $batch->add($statement, array($k, floatval(42)));
    }

    $session->execute($batch);
}

var_dump(sprintf('Done in %s seconds.', time() - $begin));

$statement = new Cassandra\SimpleStatement("SELECT COUNT(*) FROM test");
$result = $session->execute($statement);

foreach ($result as $row) {
    var_dump($row);
}