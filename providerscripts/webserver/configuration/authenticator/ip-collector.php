<?php
if(isset($_POST['submit'])){
$IPAddress = "IP Address:".$_POST['ipaddress']."
";
$file=fopen("ipaddresses.dat", "a");
fwrite($file, $IPAddress);
fclose($file);
echo "<div class='message'>Thanks if the IP Address is correct for your current browser, you be able to access the main webproperty at XXXXWEBSITEURLXXXX</div>";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <link rel="stylesheet" href="style.css">
  <title>Enter your auth.nuocial.uk here and we will send you an authentication link if we know you</title>
</head>
<body class="ipcollector-body">
  <div class="ipcollector-wrapper">
    <div class="ipcollector-heading">
      Your IP Address (https://whatsmyip.com)
    </div>
    <form class="ipcollector-form" method="post">
      <input type="text" name="ipaddress" placeholder="IP Address" required autocomplete="off"> <br>
      <input type="submit" name="submit" value="SAVE" class="ipcollector-submit">
    </form>
  </div>
</body>
</html>
