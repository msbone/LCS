<?php
function bytesToSize($bytes, $precision = 2)
{
    $kilobyte = 1024;
    $megabyte = $kilobyte * 1024;
    return round($bytes / $megabyte, $precision);
}

header ('Content-Type: image/png');
$im = imagecreatefrompng('area15.png');
if($_GET["big"] == 1) {
  $white = ImageColorAllocate($im,67,74,84);
}else {
 $white = ImageColorAllocate($im,0xFF,0xFF,0xFF);
}

$black = ImageColorAllocate($im,00,00,00);
$green = ImageColorAllocate($im,00,255,00);
$red = ImageColorAllocate($im,255,00,00);
$blue = ImageColorAllocate($im,00,00,255);

 imagefill($im, 0, 0, $white);

$textcolor = imagecolorallocate($im, 255, 255, 255);
$time = date('H:i:s');
 imagestring($im, 2, 10, 10, "Created: $time", $textcolor);

include("../database.php");

#Get all the uplinks for the last 220 sec
#$sql = "SELECT ports_poll.bytes_in, ports_poll.bytes_out, ports_poll.time, switches.name, ports.ifName,switches.id AS swid,ports.id AS portid, placements.x1,placements.x2,placements.y1,placements.y2
#FROM ports_poll
#JOIN ports, switches
#JOIN placements ON switches.id = placements.switch
#WHERE ports.id = ports_poll.port AND switches.id = ports_poll.switch AND  time >= ( UNIX_TIMESTAMP( NOW( ) ) - 220)
#ORDER BY switches.id, ports.id, port_poll.time";

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
$speed = bytesToSize($bits_totalt[$row["id"]]*8);

$red = (255 * $speed) / 2048;
$green = (255 * (2048 - $speed)) /2048;

$color = ImageColorAllocate($im,$red, $green,00);
   ImageFilledRectangle($im,$row["x2"],$row["y2"],$row["x1"],$row["y1"],$color);
    $textcolor = imagecolorallocate($im, 255, 255, 255);
 imagestring($im, 3, $row["x2"], $row["y2"], " ".$row["name"]." ".bytesToSize($bits_totalt[$row["id"]]*8), $textcolor);
}

 ImagePNG($im);
 imagedestroy($im);
