<?php
function netmask2cidr($netmask)
{
  $bits = 0;
  $netmask = explode(".", $netmask);

  foreach($netmask as $octect)
  $bits += strlen(str_replace("0", "", decbin($octect)));

  return $bits;
}
?>

<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
<?php


session_start();
include("../database.php");

$raw_input = explode(".",$_GET["id"]);

$placement = $raw_input[0]."/".$raw_input[1];

$sql = "SELECT switches.distro_id, switches.distro_port, switches.net_id FROM `switches`
WHERE switches.placement = '$placement'";

$switch_found = false;
$distro_set = true;
$distro_port_set = true;
$network_set = true;

$result = mysqli_query($con,$sql);
while($row = mysqli_fetch_array($result))
{
  $switch_found = true;
    if($row["distro_id"] == NULL or $row["distro_id"] == "") {
    //Distro not set
    $distro_set = false;
  }
  elseif ($row["distro_port"] == NULL or $row["distro_port"] == "") {
    //Distro port not set
    $distro_port_set = false;
  }
  elseif($row["net_id"] == NULL or $row["net_id"] == "") {
    //Network not set
    $network_set = false;
  }
}

if($distro_set && $network_set && $switch_found) {
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

  echo "Fill in the name, select a network, then give ip <br />";

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

//Get the vlan from cores
$sql = "SELECT id, name, network, subnet, coreswitch FROM netlist WHERE coreswitch IS NOT NULL";


$result = mysqli_query($con,$sql);
while($row = mysqli_fetch_array($result))
{
  $core_id = $row["coreswitch"];
  $net_id = $row["id"];
  $net_name = $row["name"];
  $net_network = $row["network"]."/".netmask2cidr($row["subnet"]);
  // ID, NAME (NETWORK)
    $netlist[$core_id][$net_id] = $net_id. ",".$net_name." ".$net_network;
}


//GET THE PORTS LEFT ON A CORE USING THE SWITCHES TABLE AND WHAT PORTS ARE OPEN TO USE (de_ports)
$sql = "SELECT id, de_ports FROM coreswitches WHERE de_ports IS NOT NULL";

$result = mysqli_query($con,$sql);
while($row = mysqli_fetch_array($result))
{
  //First get the de ports and make a while loop (split on -) (create an array with all useable ports)
  $port_range = explode("-",$row["de_ports"]);
$core_id = $row["id"];

  for ($x = $port_range[0]; $x <= $port_range[1]; $x++) {
    $core[$core_id][$x] = $x;
  }
}

//Then get all the switches that are connected to that core
foreach ($core as $key => $core_id) {
  $sql = "SELECT id, distro_port FROM switches WHERE distro_id = $key AND distro_port IS NOT NULL";
  $result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    //Get the port they are connected on and remove it from the array created in first step
    $distro_port = $row["distro_port"];
    unset($core[$key][$distro_port]);
  }

}


  ?>
  <script type="text/javascript">
  $(document).ready(function() {

<?php
foreach ($core as $key => $core_id) {
  echo "var core$key = [";
  $first = true;
  foreach ($core_id as $ports) {
    if($first) {
      echo "$ports";
      $first = false;
    }
    else {
      echo ", $ports";
    }
  }
  echo "]; \n";
}
?>

<?php
foreach ($netlist as $key => $core_id) {
  echo "var net_core$key = [";
  $first = true;
  foreach ($core_id as $vlan) {
    if($first) {
      echo "\"$vlan\"";
      $first = false;
    }
    else {
      echo ", \"$vlan\"";
    }
  }
  echo "]; \n";
}
?>

$('#netlist').empty();
$.each(eval("net_core"+$( "#distrolist" ).val()), function(key, value) {
  var id_name = value.split(',');
  $('#netlist')
  .append($("<option></option>")
  .attr("value",id_name[0])
  .text(id_name[1]));
});

$('#portlist').empty();
$.each(eval("core"+$( "#distrolist" ).val()), function(key, value) {
  $('#portlist')
  .append($("<option></option>")
  .attr("value",value)
  .text(value));
});

$( "#distrolist" ).change(function() {

  $('#netlist').empty();
  $.each(eval("net_core"+$( "#distrolist" ).val()), function(key, value) {
    var id_name = value.split(',');
    $('#netlist')
    .append($("<option></option>")
    .attr("value",id_name[0])
    .text(id_name[1]));
  });

  $('#portlist').empty();
  $.each(eval("core"+$( "#distrolist" ).val()), function(key, value) {
    $('#portlist')
    .append($("<option></option>")
    .attr("value",value)
    .text(value));
  });
});

});

</script>

<form action="create_switch.php" method="POST">
    Switch name:<br>
    <input type="text" name="switchname"><br>
    Distro:<br>
    <select name="distrolist" id="distrolist" class="distrolist">
<?php
foreach($distro_list as $key => $value) {
  if($key == $closest_core) {
  echo "<option selected='selected' value='$key'>$value</option>";
}else {
  echo "<option value='$key'>$value</option>";
}
}
?>
    </select><br>
    Distro_port:<br>
    <select name="portlist" id="portlist" class="portlist"></select><br>
    Network:<br>
    <select name="netlist" id="netlist" class="netlist"></select><br>
    IP-address:<br>
    <input type="text" name="ipaddress"><br>
    Placement:<br>
    <input type="text" name="placement" value="<?php echo $placement; ?>"><br>

    <input type="submit" id="submit" value="Make switch">
  </form>
  <?php

}
