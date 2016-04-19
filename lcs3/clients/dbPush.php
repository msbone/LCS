<?php
require_once __DIR__.'/vendor/autoload.php';
use PhpAmqpLib\Connection\AMQPStreamConnection;
$connection = new AMQPStreamConnection('localhost', 5672, 'guest', 'guest');
$channel = $connection->channel();

$channel->queue_declare('events', false, false, false, false);

$servername = "localhost";
$username = "root";
$password = "Dataparty16";
$dbname = "lcs";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);
// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

echo ' [*] Waiting for messages. To exit press CTRL+C', "\n";

$callback = function($msg)use($conn) {
    echo " [x] Received ", $msg->body, "\n";
    $data = json_decode($msg->body);

    $sql = "INSERT INTO ping (deviceId, latencyMs, time)
VALUES ($data->id, $data->latency, $data->time)";

    if ($conn->query($sql) === FALSE) {
        echo "Error: " . $sql . "<br>" . $conn->error;
    }

    $msg->delivery_info['channel']->basic_ack($msg->delivery_info['delivery_tag']);
};

$channel->basic_consume('events', '', false, false, false, false, $callback);

while(count($channel->callbacks)) {
    $channel->wait();
}


