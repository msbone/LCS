<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
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
  echo "Fill in the name, and the script should take care of the rest <br />";

$closest_core = 0;
$closest_distance = 1000;

//Calculate the closest core
  $switch_x = $raw_input[0];
  $switch_y = $raw_input[1];
  //Get all the coreswitches with de port set
  $sql = "SELECT id, placement, name, de_ports from coreswitches WHERE de_ports IS NOT NULL";

  $result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    $raw_ports = explode("-",$row["de_ports"]);
    for ($x = $raw_ports[0]; $x <= $raw_ports[1]; $x++) {
      $distro_total_ports[$row["id"]] = $x;
    }

    $distro_list[$row["id"]] = $row["name"];
     $raw_core_placement = explode("/",$row["placement"]);
     $raw_core_placement_x = $raw_core_placement[0];
     $raw_core_placement_y = $raw_core_placement[1];
     $x_distance = $switch_x - $raw_core_placement_x;
     $y_distance = $switch_y - $raw_core_placement_y;
     $calculated_distance = abs($x_distance) + abs($y_distance);

     if($closest_distance > $calculated_distance) {
       $closest_distance = $calculated_distance;
       $closest_core = $row["id"];
     }
  }
  echo $closest_core.": ". $closest_distance  ."<br />";

  ?>
  <script type="text/javascript">
  $(document).ready(function() {
var core1 = [1, 2, 3, 4, 5];
var core2 = [2, 3, 4, 5];

$( "#distrolist" ).change(function() {

  $('#portlist').empty();
  $.each(eval("core"+$( "#distrolist" ).val()), function(key, value) {
    $('#portlist')
    .append($("<option></option>")
    .attr("value",key)
    .text(value));
  });
});

});

</script>

  <form>
    Switch name:<br>
    <input type="text" name="switchname"><br>
    Distro:<br>
    <select id="distrolist" class="distrolist">
<?php
foreach($distro_list as $key => $value) {
  echo "<option value='$key'>$value</option>";
}
?>
    </select><br>
    Distro_port:<br>
    <select id="portlist" class="portlist">

    </select><br>
    Vlan:<br>
    <input type="text" name="vlan"><br>
    IP-address:<br>
    <input type="text" name="ipaddress"><br>
  </form>
  <?php

}
