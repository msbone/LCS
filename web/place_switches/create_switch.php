<?php
include("../database.php");

if($_POST) {
  echo "Lets do the magic";
echo $switch_name = $_POST["switchname"];
echo $switch_distro = $_POST["distrolist"];
echo $switch_distro_port = $_POST["portlist"];
echo $switch_network = $_POST["netlist"];
echo $switch_ip = $_POST["ipaddress"];
echo $switch_placement = $_POST["placement"];

if($switch_name == "") {
  echo "The switch need a name!"."<br/>";
}
elseif($switch_distro == "") {
  echo "The switch need a distro!"."<br/>";
}
elseif($switch_distro_port == "") {
  echo "The switch need a distro_port!"."<br/>";
}
elseif($switch_network == "") {
  echo "The switch need a network!"."<br/>";
}
elseif($switch_ip == "") {
  echo "The switch need a ip!"."<br/>";
}
else {
  //Add the switch to the database
  mysqli_query($con,"INSERT INTO switches (name, distro_id, distro_port, model, ip, net_id, placement)
  VALUES ('".$switch_name."','".$switch_distro."','".$switch_distro_port."','dgs24','".$switch_ip."','".$switch_network."','".$switch_placement."')");

  header("Location: /place_switches/");
  die();
}

}else {
die("Nothing to see here");
}

?>
