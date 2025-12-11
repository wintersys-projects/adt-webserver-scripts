<?php
  $email = $_POST["email"];
  $file="/tmp/authentication-emails.dat";
  $data = "$email\n";
  file_put_contents($file, $data, FILE_APPEND );
  echo "<div class='message'>Email Address Submitted, if needed you should shortly receive an authentication email at $Email</div>";
  echo "<div class='message'>The Link in the email will be valid for 5 minutes</div>";

?>
