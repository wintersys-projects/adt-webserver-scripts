<?php
if(isset($_POST['submit'])){
$Email = "Email:".$_POST['email']."
";
$file=fopen("emails.dat", "a");
fwrite($file, $Email);
fclose($file);
echo "<div class='message'>Email Address Submitted, if needed you should shortly receive an authentication email at $Email</div>";
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <link rel="stylesheet" href="style.css">
  <title>Enter your XXXXWEBSITEURLXXXX email address here and we will send you an authentication link if we know you</title>
</head>
<body class="emailcollector-body">
  <div class="emailcollector-wrapper">
    <div class="emailcollector-heading">
      Your Email Address
    </div>
    <form class="emailcollector-form" method="post">
      <input type="email" name="email" placeholder="Email Address" pattern=".*@XXXXUSEREMAILDOMAINXXXX" required autocomplete="off"> <br><br>
      <input type="submit" name="submit" value="SAVE" class="emailcollector-submit">
    </form>
  </div>
</body>
</html>
