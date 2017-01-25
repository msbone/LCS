<?php

require '../vendor/autoload.php';

include("../database.php");
/* Include the pData class */
include("pChart2.1.4/class/pDraw.class.php");
include("pChart2.1.4/class/pImage.class.php");
include("pChart2.1.4/class/pData.class.php");

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

$client = new InfluxDB\Client('localhost', 8086);
$database = $client->selectDB('lcs');
$result = $database->query('SELECT derivative(last("bytes_recv"), 1s) *8 AS bytes_recv, derivative(last("bytes_sent"), 1s) *8 AS bytes_sent FROM "net" WHERE "lcs_interface_id" = \'6\' AND time > now() - 1h GROUP BY time(1s) fill(null)');
$points = $result->getPoints();

foreach ($points as $key => $value) {
  $timestamp[]   = date("H:i", strtotime($value["time"]));
  $bits_in[] = $value['bytes_recv'];
  $bits_out[] = $value['bytes_sent'];
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
    $value = $value;
}
foreach ($bits_out as &$value) {
  $value = $value;
}
}
elseif($size == 1) {
  $size = "Kb";
  foreach ($bits_in as &$value) {
    $value = round($value / $kilobyte, 5);
}
foreach ($bits_out as &$value) {
  $value = round($value / $kilobyte, 5);
}
} elseif($size == 2) {
  $size = "Mb";
  foreach ($bits_in as &$value) {
    $value = round($value / $megabyte, 5);
}
foreach ($bits_out as &$value) {
  $value = round($value / $megabyte, 5);
}
} elseif($size == 3) {
  $size = "Gb";
  foreach ($bits_in as &$value) {
    $value = round($value / $gigabyte, 5);
}
foreach ($bits_out as &$value) {
  $value = round($value / $gigabyte, 5);
}
} elseif($size == 4) {
  $size = "Tb";
  foreach ($bits_in as &$value) {
    $value = round($value / $terabyte, 5);
}
foreach ($bits_out as &$value) {
  $value = round($value / $terabyte, 5);
}
}

/* Create the pData object */
$myData = new pData();

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
$myPicture->setFontProperties(array("FontName"=>"pChart2.1.4/fonts/SourceCodePro-Light.ttf","FontSize"=>10));
$myPicture->setGraphArea(40,40,681,220);
$myPicture->drawScale(array("Mode"=>SCALE_MODE_START0,"LabelSkip"=>5));
$myPicture->drawFilledSplineChart();
$myPicture->drawText(60,35,'test',array("FontSize"=>18,"Align"=>TEXT_ALIGN_BOTTOMLEFT));
#header('Content-Type: image/png');
$myPicture->Stroke();
