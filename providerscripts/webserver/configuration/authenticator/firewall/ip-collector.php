<!DOCTYPE html>
<html>

<head>
    <title>Enter the IP Address that you want to allow access to</title>
    <link rel="stylesheet" href="style.css">
</head>

<body>
    <div class="main">
        <h1>Laptop IP Address to allow access for</h1>
        <h3>Please enter the IP Address of your laptop</h3>
        <h3>If you don't know what it is you can go to</h3>
        <a href="https://www.whatsmyip.com/">What's my laptop IP?</a>
        <form action="submit1.php" method="post">
          <label for="IPAddress">IPAddress:</label>
            <input type="text" name="ipaddress" placeholder="IP Address" required autocomplete="off"> <br>                
            <input type="submit" value="Submit">
        </form>
    </div>
</body>

</html>
