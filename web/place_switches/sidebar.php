<?php
session_start();
include("../database.php");

$raw_input = explode(".",$_GET["id"]);

$placement = $raw_input[0]."/".$raw_input[1];

$sql = "SELECT switches.distro_id, switches.distro_port, switches.net_id FROM `switches`
WHERE switches.placement = '$placement'";

$result = mysqli_query($con,$sql);
while($row = mysqli_fetch_array($result))
{
  if($row["switches.distro_id"] == null or $row["switches.distro_id"] == "") {
    //Distro not set
  }
  elseif ($row["switches.distro_port"] == null or $row["switches.distro_port"] == "") {
    //Distro port not set
  }
  elseif($row["switches.net_id"] == null or $row["net_id"] == "") {
    //Network not set
  }
}

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
