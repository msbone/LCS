<?php
include("database.php");

$return_arr = array();
#Grap all the switches and put them in an array
$sql = "SELECT switches.id,switches.name,placements.x1,placements.x2,placements.y1,placements.y2 FROM `switches` JOIN `placements` WHERE switches.id = placements.switch";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    $row_array['sysname'] = $row['name'];
    $row_array['x'] = $row['x2'];
    $row_array['width'] = $row['x1'] - $row['x2'];
    $row_array['y'] = $row['y2'];
    $row_array['height'] = $row['y1'] - $row['y2'];
    $row_array['zorder'] = 0;

    $return_arr[$row['id']] = $row_array;

}

header('Content-Type: application/json');
echo json_encode(array("switches" => $return_arr));
