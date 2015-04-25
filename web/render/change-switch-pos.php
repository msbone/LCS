<?php
include("../database.php");
if($_POST["switch"] == null or $_POST["x"] == null or $_POST["y"] == null) {
  die("bad input");
}

$sql = "SELECT placements.x1,placements.x2,placements.y1,placements.y2 FROM `switches` JOIN `placements` WHERE switches.id = placements.switch AND switches.id = '".$_POST["switch"]."'";

echo $sql;

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
  $old_x1 = $row["x1"];
  $old_x2 = $row["x2"];
  $old_y1 = $row["y1"];
  $old_y2 = $row["y2"];
  $old_width = $old_x1 - $old_x2;
  $old_height = $old_y1 - $old_y2;
  }

$new_x1 = $_POST["x"] + $old_width;
$new_y1 = $_POST["y"] + $old_height;
$new_x2 = $_POST["x"];
$new_y2 = $_POST["y"];

mysqli_query($con,"UPDATE  `placements` SET  `x1` =  '".$new_x1."',`y1` =  '".$new_y1."',`x2` =  '".$new_x2."',`y2` =  '".$new_y2."' WHERE  `switch` ='".$_POST["switch"]."'");
