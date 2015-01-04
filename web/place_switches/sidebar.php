<?php
session_start();
include("../database.php");

$raw_input = explode(".",$_GET["id"]);

$placement = $raw_input[0]."/".$raw_input[1];

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
