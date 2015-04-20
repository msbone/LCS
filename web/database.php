<?php
$db_password = file_get_contents('../include/db_password.txt') or die("WHOOPS");

$con=mysqli_connect("localhost","lcs",$db_password,"lcs"); #TODO, GET THE USER FROM config.pm (some magic)

// Check connection
if (mysqli_connect_errno($con))
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
if (!mysqli_set_charset($con, "utf8")) {
  printf("Error loading character set utf8: %s\n", mysqli_error($link));
}
