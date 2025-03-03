<?php
if(isset($_POST['submit'])){
$Name = "Email:".$_POST['email']."
";
$file=fopen("emails.dat", "a");
fwrite($file, $Name);
aved/write($file, $Pass);
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
  <title>My HTML Form</title>
</head>
<body class="emailcollector-body">
  <div class="emailcollector-wrapper">
    <div class="emailcollector-heading">
      My HTML Form
    </div>
    <form class="emailcollector-form" method="post">
      <input type="text" name="email" placeholder="Email Address" required autocomplete="off"> <br>
      <input type="submit" name="submit" value="SAVE" class="emailcollector-submit">
    </form>
  </div>
</body>
</html>
