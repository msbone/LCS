<?php
session_start();
//Get the user input from seatmap, then do magic (place or remove switch) kant

include("../database.php");

$raw_input = explode(".",$_POST["seat"]);

$placement = $raw_input[0]."/".$raw_input[1];

$sql = "SELECT switches.id FROM `switches`
WHERE switches.placement = '$placement'";

$result = mysqli_query($con,$sql);
while($row = mysqli_fetch_array($result))
{
  //switch exist;
  die("There is an switch already");
}

$name = "Switch. $placement";
//Place the switch
mysqli_query($con,"INSERT INTO switches (name, placement)
VALUES ('".$name."','".$placement."')");




?>
