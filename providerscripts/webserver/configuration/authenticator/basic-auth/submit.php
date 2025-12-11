<?php
  $email = $_POST["email"];
  $password = $_POST["password"];
  $file="/tmp/basic-auth.dat";
  $data = "$email:$password\n";
  file_put_contents($file, $data, FILE_APPEND );
  echo "<h2>Your basic auth password has been set.</h2>";
  echo "<h2>Please enter this email address and this password when visiting our main website.</h2>";
?>
