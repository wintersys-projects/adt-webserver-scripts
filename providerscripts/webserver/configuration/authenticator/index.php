<?php
if(isset($_POST['submit'])){
$Email = "Email:".$_POST['email']."
";
$file=fopen("emails.dat", "a");
fwrite($file, $Email);
fclose($file);
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <link rel="stylesheet" href="style.css">
  <title>Enter your XXXXWEBSITEURLXXXX here and we will send you an authentication link if we know you</title>
</head>
<body class="emailcollector-body">
  <div class="emailcollector-wrapper">
    <div class="emailcollector-heading">
      Your Email Address
    </div>
    <form class="emailcollector-form" method="post">
      <input type="text" name="email" placeholder="Email Address" required autocomplete="off"> <br>
      <input type="submit" name="submit" value="SAVE" class="emailcollector-submit">
    </form>
  </div>
</body>
</html>
