<?php
$dbport=(int) $argv[5];
$conn = pg_connect("host=$argv[1] port=$dbport dbname=$argv[4] user=$argv[2] password=$argv[3]");
   if(!$conn)
   {
     echo "DEAD";
   }
   $result = pg_query($conn, "select exists ( select 1 from information_schema.tables );");
   if(!$result)
   {
      echo pg_last_error($conn);
      exit;
   }
   $result = pg_fetch_result($result,0,0);

   if (strpos($result, 't') !== false)
   {
      echo "ALIVE";
   }
   else
   {
      echo "DEAD";
   }
   pg_close()
?>
