<?php
  $ipaddress = $_POST["ipaddress"];
  $file="/tmp/ipaddresses.dat";
  $data = "$ipaddress\n";
  file_put_contents($file, $data, FILE_APPEND );
  echo "<h2>Access for your IP Address has been requested it might take up to a minute, any longer and there is a problem.</h2>";
?>
