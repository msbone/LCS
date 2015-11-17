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
  <h1>Area51-LAN <small>LCS</small></h1>
</div>
       <div class="span12">
<?php
include("../database.php");
$local_ip = $_SERVER['REMOTE_ADDR'];

if($local_ip == "83.243.195.22") {
  echo "<h3> Beklager </h3>";
  echo "Men dette sytemet funker kun på kablet nettverk <br />";
} else {

$sql = "SELECT mac_table.ip, switches.name, ports.ifName, ports.id, mac_table.mac,dhcp_leases.name AS dhcpname FROM mac_table JOIN switches ON mac_table.switch = switches.id
LEFT JOIN dhcp_leases ON dhcp_leases.mac = mac_table.mac
JOIN ports WHERE ports.switch_id = switches.id AND ports.id = mac_table.port
AND mac_table.ip = '$local_ip' LIMIT 1";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    if($row["dhcpname"] != null) {
    echo "<h3> Hei ".$row["dhcpname"]."</h3>";
  }else {
    echo "<h3> Hei </h3>";
  }
echo "Du er koblet til switch <b>".$row["name"]. ":" .$row["ifName"] . "</b> med ip $local_ip og mac ".$row["mac"]."<br/>";
echo "Her er din graph: <br/>";
echo '<img src="/make_port_graph.php?port='.$row["id"].'&time=3600"/> <br/>';
echo '<img src="/make_port_graph.php?port='.$row["id"].'&time=21600"/> ';
  }
  if(mysqli_num_rows($result) == 0) {
    echo "<h3> Beklager </h3>";
    echo "Vi klarte ikke å finne din ip, $local_ip <br /> <br /> <small>lol</small>";
  }
}

 ?>
 </div>
 </div><!-- /.container -->     <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js" integrity="sha512-K1qjQ+NcF2TYO/eI3M6v8EiNYZfA95pQumfvcVrTHtwQVDG+aHRqLi/ETn2uB+1JqwYqVG3LIvdm9lj6imS/pQ==" crossorigin="anonymous"></script>
  </body>
</html>
