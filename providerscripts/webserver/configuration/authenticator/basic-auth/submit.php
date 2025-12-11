<?php
  $email = $_POST["email"];
  $password = $_POST["password"];
  $file="/tmp/basic-auth.dat";
  $data = "$email:$password\n";
  file_put_contents($file, $data, FILE_APPEND );
  echo "<div class='message'><h2>Your basic auth password has been set. Please enter your email address and password when visiting our main website.</h2></div>";
?>
