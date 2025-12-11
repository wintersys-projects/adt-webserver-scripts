<?php
  $email = $_POST["email"];
  $file="/tmp/authentication-emails.dat";
  $data = "$email\n";
  file_put_contents($file, $data, FILE_APPEND );
  echo "<h2>Email Address Submitted, if needed you should shortly receive an authentication email at $email.</h2>";
  echo "<h2>The Link in the email will be valid for 5 minutes.</h2>";

?>
