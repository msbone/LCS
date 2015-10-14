<?php
include("../database.php");
/* Include the pData class */
include("pChart2.1.4/class/pDraw.class.php");
include("pChart2.1.4/class/pImage.class.php");
include("pChart2.1.4/class/pData.class.php");

/* Create the pData object */
$myData = new pData();

#$sql = "select latency_ms,updated from switches_ping WHERE updated >= ( UNIX_TIMESTAMP( NOW( ) ) - 50 ) AND switch = 2";
#$sql = "SELECT AVG(latency_ms), HOUR(from_unixtime(updated)), DATE(from_unixtime(updated)) FROM switches_ping WHERE DATE_SUB(from_unixtime(updated),INTERVAL 1 HOUR) AND updated >= ( UNIX_TIMESTAMP( NOW( ) ) - 86400 ) AND latency_ms IS NOT NULL GROUP BY DATE( from_unixtime(updated) ), HOUR(from_unixtime(updated)) ORDER BY updated ASC";
$sql = "SELECT time, temp FROM temp WHERE device = 1 AND FROM_UNIXTIME(time) >= DATE_SUB(NOW(),INTERVAL 2 HOUR)";
$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
 $timestamp[]   = date("H:i",$row["time"]);
 $temprature[] = $row["temp"];
}

/* Save the data in the pData array */
// $myData->addPoints($timestamp,"Timestamp");
// $myData->addPoints($latency_ms,"latency_ms");
// $myData->setAbscissa("Timestamp");
//
// $serieSettings = array("R"=>229,"G"=>11,"B"=>11,"Alpha"=>100);
// $myData->setPalette("latency_ms",$serieSettings);
//
// $myPicture = new pImage(1920,1000,$myData);
// $myPicture->setFontProperties(array("FontName"=>"pChart2.1.4/fonts/SourceCodePro-Light.ttf","FontSize"=>10));
// $myPicture->setGraphArea(60,40,1900,900);
// $myPicture->drawScale();
// $myPicture->drawSplineChart();
// $myPicture->drawText(60,35,"Temp last hour",array("FontSize"=>20,"Align"=>TEXT_ALIGN_BOTTOMLEFT));
// header('Content-Type: image/png');
// $myPicture->Render("");


$myData->addPoints($timestamp,"Timestamp");
$myData->addPoints($temprature,"Temprature");
$myData->setAbscissa("Timestamp");
$myData->setAxisName(0,$size);
$myData->setAxisUnit(0,"°C");

$serieSettings = array("R"=>11,"G"=>11,"B"=>229,"Alpha"=>100);
$myData->setPalette("Temprature",$serieSettings);

$myPicture = new pImage(1980,1000,$myData);
$myPicture->setFontProperties(array("FontName"=>"pChart2.1.4/fonts/SourceCodePro-Light.ttf","FontSize"=>10));
$myPicture->setGraphArea(40,40,1900,800);
$myPicture->drawScale(array("Mode"=>SCALE_MODE_START0,"LabelSkip"=>4));
$myPicture->drawLineChart();
$myPicture->drawText(60,35,"Temprature - Soverom | 2 HOUR",array("FontSize"=>18,"Align"=>TEXT_ALIGN_BOTTOMLEFT));
#header('Content-Type: image/png');
$myPicture->Stroke();
