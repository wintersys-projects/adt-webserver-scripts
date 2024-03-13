<?php
$servername = $argv[1];
$username = $argv[2];
$password = $argv[3];
$dbname = $argv[4];
$serverport = (int) $argv[5];

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname, $serverport);

if ($conn -> connect_errno) {
  echo "Failed to connect to MySQL: " . $comm -> connect_error;
  exit();
}

// Perform query
if ($result = $conn -> query("show tables")) {
  echo "ALIVE";
  $result -> free_result();
}


$conn->close();
?>
