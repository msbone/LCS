<?php
header ('Content-Type: image/png');
$im = imagecreatefrompng('vlan15.png');
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

$sql = "SELECT switches.latency_ms,switches.name,placements.x1,placements.x2,placements.y1,placements.y2 FROM `switches` JOIN `placements` WHERE switches.id = placements.switch";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
if($row["latency_ms"] < 100){
   ImageFilledRectangle($im,$row["x2"],$row["y2"],$row["x1"],$row["y1"],$green);
    $textcolor = imagecolorallocate($im, 0, 0, 0);
 }
 elseif($row["latency_ms"] < 200){
    ImageFilledRectangle($im,$row["x2"],$row["y2"],$row["x1"],$row["y1"],$red);
     $textcolor = imagecolorallocate($im, 255, 255, 255);
  }
 else {
ImageFilledRectangle($im,$row["x2"],$row["y2"],$row["x1"],$row["y1"],$blue);
 $textcolor = imagecolorallocate($im, 255, 255, 255);
}
 imagestring($im, 3, $row["x2"], $row["y2"], $row["name"], $textcolor);
  }
 ImagePNG($im);
 imagedestroy($im);
