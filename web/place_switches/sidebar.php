<?php
session_start();
include("../database.php");

$raw_input = explode(".",$_GET["id"]);

$placement = $raw_input[0]."/".$raw_input[1];

$sql = "SELECT switches.distro_id, switches.distro_port, switches.net_id FROM `switches`
WHERE switches.placement = '$placement'";

$switch_found = false;
$distro_set = false;
$distro_port_set = false;
$network_set = false;

$result = mysqli_query($con,$sql);
while($row = mysqli_fetch_array($result))
{
  $switch_found = true;
    if($row["distro_id"] == null or $row["distro_id"] == "") {
    //Distro not set
    $distro_set = true;
  }
  elseif ($row["distro_port"] == null or $row["distro_port"] == "") {
    //Distro port not set
    $distro_port_set = true;
  }
  elseif($row["net_id"] == null or $row["net_id"] == "") {
    //Network not set
    $network_set = true;
  }
}

if($distro_set and $network_set) {
$sql = "SELECT switches.name, switches.distro_port, switches.model, switches.ip, switches.configured, switches.alive,
coreswitches.name AS corename, netlist.name AS netname, netlist.vlan FROM `switches` JOIN `coreswitches`, `netlist`
WHERE switches.placement = '$placement' AND switches.net_id = netlist.id AND switches.distro_id = coreswitches.id";

$result = mysqli_query($con,$sql);
while($row = mysqli_fetch_array($result))
{
echo "<h2>".$row["name"]."</h2>";
if($row["alive"] == 1) {
  echo "<b>ALIVE </b><br/>";
}
else {
  echo "<b> DEAD </b><br/>";
}
if($row["configured"] == 1) {
  echo "Configured<br/>";
}
else {
  echo "Not configured<br/>";
}
echo "IP: ".$row["ip"] ."<br/>";
echo "Distro: ".$row["corename"] ."<br/>";
echo "Distro_port: ".$row["distro_port"] ."<br/>";
echo "Netname: ".$row["netname"] ."<br/>";
echo "VLAN: ".$row["vlan"] ."<br/>";
}
}
elseif($switch_found){
  echo "The switch is found, but do not have all the settings";
  //Lets show the settings form

}

else {
  echo "There is no switch, the make switch comes here <br />";


  $switch_x = $raw_input[0];
  $switch_y = $raw_input[1];
  //Get all the coreswitches with de port set
  $sql = "SELECT * from coreswitches WHERE de_ports IS NOT NULL";

  $result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
     $raw_core_placement = explode("/",$row["placement"]);
     $raw_core_placement_x = $raw_core_placement[0];
     $raw_core_placement_y = $raw_core_placement[1];
     $x_distance = $switch_x - $raw_core_placement_x;
     $y_distance = $switch_y - $raw_core_placement_y;
     $calculated_distance = abs($x_distance) + abs($y_distance);
     echo $row["name"].": ". $calculated_distance  ."<br />";
  }

}
