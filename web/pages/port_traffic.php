<?php
include("database.php");

 if (@$_GET["id"] == null or @$_GET["id"] == "") {
  #LIST ALL PORTS ON SWITCH, WITH DAY GRAPH
  $sql = "SELECT ports.id,switches.name,ports.ifName FROM ports JOIN switches WHERE ports.switch_id = switches.id AND switches.id = '".$_GET["switch"]."' ORDER BY LENGTH(ports.ifName), ports.ifName";
  $result = mysqli_query($con,$sql);
  $found = false;
    while($row = mysqli_fetch_array($result))
    {
      echo '<div class="col-md-6"><a href="/index.php?page=port_traffic&switch='.$_GET["switch"].'&id='.$row["id"].'"> <img class="img-responsive" src="/rrd/'.$row["id"].'-hour-2.png" alt="'.$row["name"]." - ".$row["ifName"].'"></a></div>';
      $found = true;
    }
if($found == false) {
  echo "No ports found, if the switch is just added, wait...";
}
} else {
  #LIST ALL GRAPH ON THAT PORT
  $sql = "SELECT ports.id,switches.name,ports.ifName FROM ports JOIN switches WHERE ports.switch_id = switches.id AND ports.id = '".$_GET["id"]."' ORDER BY LENGTH(ports.ifName), ports.ifName";
  $result = mysqli_query($con,$sql);
  $found = false;
    while($row = mysqli_fetch_array($result))
    {
      echo '<div class="col-md-6"> <img class="img-responsive" src="/rrd/'.$row["id"].'-hour-2.png" alt="'.$row["name"]." - ".$row["ifName"].'"></div>';
      echo '<div class="col-md-6"> <img class="img-responsive" src="/rrd/'.$row["id"].'-day-2.png" alt="'.$row["name"]." - ".$row["ifName"].'"></div>';
      echo '<div class="col-md-6"> <img class="img-responsive" src="/rrd/'.$row["id"].'-week-2.png" alt="'.$row["name"]." - ".$row["ifName"].'"></div>';
      $found = true;
    }
if($found == false) {
  echo "No ports found";
}

}

?>
