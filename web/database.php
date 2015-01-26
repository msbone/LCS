<?php
$con=mysqli_connect("localhost","lcs","E06S6QuC8Ix9","lcs"); #TODO, GET THE USER AND PASSWORD FROM config.pm (some magic)

// Check connection
if (mysqli_connect_errno($con))
{
  echo "Failed to connect to MySQL: " . mysqli_connect_error();
}
if (!mysqli_set_charset($con, "utf8")) {
  printf("Error loading character set utf8: %s\n", mysqli_error($link));
}
