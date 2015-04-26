<?php
include("../database.php");

$return_arr = array();
#Grap all the switches and put them in an array
$sql = "select * from switches WHERE ip IS NOT NULL";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    $row_array['latency'] = $row['latency_ms'];

    $return_arr[$row['id']] = $row_array;

}

header('Content-Type: application/json');
echo json_encode(array("switches" => $return_arr));
