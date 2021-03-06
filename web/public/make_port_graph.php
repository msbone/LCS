<?php

if(@$_GET["port"] == "") {
  die("NO PORT SET");
}

if(@$_GET["time"] == "") {
  $end_time = 3600;
} else {
  $end_time = $_GET["time"];
}

$kilobyte = 1024;
$megabyte = $kilobyte * 1024;
$gigabyte = $megabyte * 1024;
$terabyte = $gigabyte * 1024;

function bytesToSize($bytes)
{
  $kilobyte = 1024;
  $megabyte = $kilobyte * 1024 / 8;
  $gigabyte = $megabyte * 1024 / 8;
  $terabyte = $gigabyte * 1024 / 8;

    if (($bytes >= 0) && ($bytes < $kilobyte)) {
        return 0;

    } elseif (($bytes >= $kilobyte) && ($bytes < $megabyte)) {
      return 1;

    } elseif (($bytes >= $megabyte) && ($bytes < $gigabyte)) {
      return 2;

    } elseif (($bytes >= $gigabyte) && ($bytes < $terabyte)) {
      return 3;

    } elseif ($bytes >= $terabyte) {
      return 4;
    } else {
      return 0;
    }
}

include("../database.php");
/* Include the pData class */
include("../graph/pChart2.1.4/class/pDraw.class.php");
include("../graph/pChart2.1.4/class/pImage.class.php");
include("../graph/pChart2.1.4/class/pData.class.php");

/* Create the pData object */
$myData = new pData();

#$sql = "select latency_ms,updated from switches_ping WHERE updated >= ( UNIX_TIMESTAMP( NOW( ) ) - 50 ) AND switch = 2";
#$sql = "SELECT AVG(latency_ms), HOUR(from_unixtime(updated)), DATE(from_unixtime(updated)) FROM switches_ping WHERE DATE_SUB(from_unixtime(updated),INTERVAL 1 HOUR) AND updated >= ( UNIX_TIMESTAMP( NOW( ) ) - 86400 ) AND latency_ms IS NOT NULL GROUP BY DATE( from_unixtime(updated) ), HOUR(from_unixtime(updated)) ORDER BY updated ASC";
#$sql = "SELECT ports_poll.bytes_in, ports_poll.bytes_out, ports_poll.time, switches.name, ports.ifName FROM ports_poll JOIN ports, switches WHERE ports.id = ports_poll.port AND switches.id = ports_poll.switch AND  time >= ( UNIX_TIMESTAMP( NOW( ) ) - 3600 ) AND port = '".$_GET["port"]."'";

if($end_time <= 3600) {
$sql = "SELECT ports_poll.bytes_in, ports_poll.bytes_out, ports_poll.time, switches.name, ports.ifName FROM ports_poll JOIN ports, switches WHERE ports.id = ports_poll.port AND switches.id = ports_poll.switch AND  time >= ( UNIX_TIMESTAMP( NOW( ) ) - ".$end_time." ) AND port = '".$_GET["port"]."'";
} else {

$sql = "SELECT CONCAT( DATE( FROM_UNIXTIME( TIME ) ) ,  ' ', HOUR( FROM_UNIXTIME( TIME ) ) ,  ':', ROUND( MINUTE( FROM_UNIXTIME( TIME ) ) /5, 0 ) *5 ) , MAX( ports_poll.bytes_in ) AS bytes_in , MAX( ports_poll.bytes_out ) AS bytes_out , ports_poll.time, switches.name, ports.ifName
FROM ports_poll
JOIN ports, switches
WHERE ports.id = ports_poll.port
AND switches.id = ports_poll.switch
AND ports_poll.`time` >= ( UNIX_TIMESTAMP( NOW( ) ) - ".$end_time." )
AND ports_poll.port =  '".$_GET["port"]."'
GROUP BY DATE( FROM_UNIXTIME( TIME ) ) , HOUR( FROM_UNIXTIME( TIME ) ) , ROUND( MINUTE( FROM_UNIXTIME( TIME ) ) /5, 0 ) *5";
}

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    if(@$pre_timestamp != "") {
      $time_gone = $row["time"]-$pre_timestamp;
      $current_bytes_in = ($row["bytes_in"] - $pre_bytes_in) / $time_gone;
      $current_bytes_out = ($row["bytes_out"] - $pre_bytes_out) / $time_gone;
          $timestamp[]   = date("H:i",$row["time"]);
          $bits_in[] = $current_bytes_in;
          $bits_out[] = $current_bytes_out;
    }
    $pre_timestamp = $row["time"];
    $pre_bytes_in = $row["bytes_in"];
    $pre_bytes_out = $row["bytes_out"];

$port_info = $row["ifName"]." - ".$row["name"];
}

if(mysqli_num_rows($result) <= 2) {
$myPicture = new pImage(681,244,$myData);
$myPicture->setFontProperties(array("FontName"=>"../graph/pChart2.1.4/fonts/SourceCodePro-Light.ttf","FontSize"=>20));
$myPicture->drawText(30,40,"NO DATA TO MAKE THE GRAPH!");
$myPicture->Stroke();
  die();
}



$bytes_in_max = bytesToSize(max($bits_in));
$bytes_out_max = bytesToSize(max($bits_out));

if($bytes_in_max >= $bytes_out_max) {
#in big
$size = $bytes_in_max;
} else {
#out big
$size = $bytes_out_max;
}

if($size == 0) {
  $size = "bits/s";
  foreach ($bits_in as &$value) {
    $value = $value * 8;
}
foreach ($bits_out as &$value) {
  $value = $value * 8;
}
}
elseif($size == 1) {
  $size = "Kb";
  foreach ($bits_in as &$value) {
    $value = round($value / $kilobyte, 5) * 8;
}
foreach ($bits_out as &$value) {
  $value = round($value / $kilobyte, 5) * 8;
}
} elseif($size == 2) {
  $size = "Mb";
  foreach ($bits_in as &$value) {
    $value = round($value / $megabyte, 5) * 8;
}
foreach ($bits_out as &$value) {
  $value = round($value / $megabyte, 5) * 8;
}
} elseif($size == 3) {
  $size = "Gb";
  foreach ($bits_in as &$value) {
    $value = round($value / $gigabyte, 5) * 8;
}
foreach ($bits_out as &$value) {
  $value = round($value / $gigabyte, 5) * 8;
}
} elseif($size == 4) {
  $size = "Tb";
  foreach ($bits_in as &$value) {
    $value = round($value / $terabyte, 5) * 8;
}
foreach ($bits_out as &$value) {
  $value = round($value / $terabyte, 5) * 8;
}
}
/*
foreach ($bits_out as &$value) {
  echo $value ." - <br>";
}
echo "<br>";
foreach ($bits_in as &$value) {
 echo $value ." - <br>";
}

*/
/* Save the data in the pData array*/
if(@$_GET["big"] == 1) {
$myData->addPoints($timestamp,"Timestamp");
$myData->addPoints($bits_in,"bits_in");
$myData->addPoints($bits_out,"bits_out");
$myData->setAbscissa("Timestamp");
$myData->setAxisName(0,$size);
$serieSettings = array("R"=>5,"G"=>190,"B"=>213,"Alpha"=>100);
$myData->setPalette("bits_in",$serieSettings);
$myData->setSerieWeight("bits_in",2);
$serieSettings = array("R"=>141,"G"=>72,"B"=>171,"Alpha"=>100);
$myData->setPalette("bits_out",$serieSettings);
$myData->setSerieWeight("bits_out",2);

$myPicture = new pImage(1362,488,$myData);
$myPicture->drawFilledRectangle(00,00,1362,488,array("R"=>67,"G"=>74,"B"=>84));
$myPicture->setFontProperties(array("FontName"=>"../graph/pChart2.1.4/fonts/SourceCodePro-Light.ttf","FontSize"=>16,"R"=>227,"G"=>231,"B"=>236));
$myPicture->setGraphArea(80,60,1362,400);
$myPicture->drawScale(array("Mode"=>SCALE_MODE_START0,"LabelSkip"=>5));
$myPicture->drawLineChart();
#header('Content-Type: image/png');
$myPicture->Stroke();
} else {
  $myData->addPoints($timestamp,"Timestamp");
  $myData->addPoints($bits_in,"bits_in");
  $myData->addPoints($bits_out,"bits_out");
  $myData->setAbscissa("Timestamp");
  $myData->setAxisName(0,$size);

  $serieSettings = array("R"=>229,"G"=>11,"B"=>11,"Alpha"=>100);
  $myData->setPalette("bits_in",$serieSettings);
  $serieSettings = array("R"=>11,"G"=>11,"B"=>229,"Alpha"=>100);
  $myData->setPalette("bits_out",$serieSettings);

  $myPicture = new pImage(681,244,$myData);
  $myPicture->setFontProperties(array("FontName"=>"../graph/pChart2.1.4/fonts/SourceCodePro-Light.ttf","FontSize"=>10));
  $myPicture->setGraphArea(50,50,681,220);
  $myPicture->drawScale(array("Mode"=>SCALE_MODE_START0,"LabelSkip"=>5));
  $myPicture->drawLineChart();
  $myPicture->drawText(60,35,$port_info,array("FontSize"=>18,"Align"=>TEXT_ALIGN_BOTTOMLEFT));
  #header('Content-Type: image/png');
  $myPicture->Stroke();
}
