<?php
include ("../database.php");

//Reads the temprature then log to database
$temp = $_POST["temp"];

if($temp == 0 or $temp == null) { die("Temp must be set");}

$time = time();
$device = 1;

mysqli_query($con,"INSERT INTO temp (`time`,`device`,`temp`)
VALUES ('".$time."','".$device."','".$temp."')") or die(mysqli_error($con));
