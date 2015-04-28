<?php
include("../database.php");

$return_arr = array();
#Grap all the switches and put them in an array
$sql = "select id,latency_ms,updated from switches WHERE ip IS NOT NULL";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    $date = new DateTime();
    $current = $date->getTimestamp();
    $last_accepted_time = $current -5;
    if($row['updated'] < $last_accepted_time) {
      $row_array['latency'] = "null";
    } else {
    $row_array['latency'] = $row['latency_ms']; #The render.js is weird about colors;
  }
    $return_arr[$row['id']] = $row_array;
}

header('Content-Type: application/json');
echo json_encode(array("switches" => $return_arr));
