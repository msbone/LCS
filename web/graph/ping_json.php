<?php
include("../database.php");
$return_arr = array();
#Grap all the switches and put them in an array
$sql = "select latency_ms,updated from switches_ping WHERE updated >= ( UNIX_TIMESTAMP( NOW( ) ) - 120 ) AND switch = 2";
$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
	$time = date("H:i:s",$row['updated']);
    $row_array['latency'] = $row['latency_ms'];
    $return_arr[$time] = $row_array;
}
header('Content-Type: application/json');
echo json_encode($return_arr);
