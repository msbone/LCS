<?php
include("../database.php");

$return_arr = array();
#Grap all the switches and put them in an array
$sql = "SELECT SUM( bytes_in ) AS bytes_in, SUM( bytes_out ) AS bytes_out,  `time` , switches.id
FROM  `ports_poll`
JOIN switches ON ports_poll.switch = switches.id
WHERE TIME >= ( UNIX_TIMESTAMP( NOW( ) ) -120 )
AND ports_poll.switch = switches.id
GROUP BY MINUTE( FROM_UNIXTIME(  `time` ) ) , switches.id
ORDER BY  ports_poll.switch,ports_poll.port,ports_poll.time
";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    if(@$pre_timestamp != "") {
      $time_gone = $row["time"]-$pre_timestamp;
    $current_bytes_in = ($row["bytes_in"] - $pre_bytes_in) / $time_gone;
    $current_bytes_out = ($row["bytes_out"] - $pre_bytes_out) / $time_gone;
          $bits_totalt[$row["id"]] = $current_bytes_in + $current_bytes_out;
    }
    $pre_timestamp = $row["time"];
    $pre_bytes_in = $row["bytes_in"];
    $pre_bytes_out = $row["bytes_out"];
}

$sql = "SELECT switches.name,placements.x1,placements.x2,placements.y1,placements.y2,switches.id FROM `switches` JOIN `placements` WHERE switches.id = placements.switch";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    $row_array['latency'] = $bits_totalt[$row["id"]]/1800000;
    $return_arr[$row['id']] = $row_array;
}

header('Content-Type: application/json');
echo json_encode(array("switches" => $return_arr));
