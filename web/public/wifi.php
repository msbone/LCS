<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>LCS - Public</title>

    <!-- Bootstrap -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css" integrity="sha512-dTfge/zgoMYpP7QbHy4gWMEGsbsdZeCXz7irItjcC3sPUFtf0kuFbDz/ixG7ArTxmDjLXDmezHubeNikyKGVyQ==" crossorigin="anonymous">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
   <body>
     <div class="container">
       <div class="page-header">
  <h1>Area51-LAN <small>LCS WiFi</small></h1>
</div>
       <div class="span12">
<?php
include("../database.php");
$local_ip = $_SERVER['REMOTE_ADDR'];


if($local_ip == '213.184.213.162'){
  $local_ip = '10.0.1.10';
}

$sql = "SELECT *  FROM ap_clients JOIN aps ON ap_clients.ap_id = aps.id WHERE ap_clients.ip='".$local_ip."'";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    if($row["hostname"] != null) {
    echo "<h3> Hei ".$row["hostname"]."</h3>";
  }else {
    echo "<h3> Hei </h3>";
  }
  ?>
Du er påkoblet <?= $row['essid'] ?>:<b><?= $row['name'] ?> </b> <br/>
Kanal <?= $row['radio_proto'] ?>:<?= $row['channel'] ?> Styrke: <?= $row['signal_strength'] ?><br/>
<?php
  }
  if(mysqli_num_rows($result) == 0) {
    echo "<h3> Beklager </h3>";
    echo "Vi klarte ikke å finne din ip, $local_ip <br /> <br /> <small>lol</small>";
  }

 ?>
 </div>
 </div><!-- /.container -->     <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" integrity="sha512-K1qjQ+NcF2TYO/eI3M6v8EiNYZfA95pQumfvcVrTHtwQVDG+aHRqLi/ETn2uB+1JqwYqVG3LIvdm9lj6imS/pQ==" crossorigin="anonymous"></script>
  </body>
</html>
