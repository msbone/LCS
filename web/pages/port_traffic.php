<?php
include("database.php");

 if (@$_GET["id"] == null or @$_GET["id"] == "") {
  #LIST ALL PORTS ON SWITCH

  if($_GET["time"] == 3600 OR $_GET["time"] == "") {
    $time = 3600;
  }
  else {
    $time = $_GET["time"];
  }



  $sql = "SELECT switches.name FROM switches WHERE switches.id = '".$_GET["switch"]."'";
  $result = mysqli_query($con,$sql);
  $found = false;
    while($row = mysqli_fetch_array($result))
    {
      echo "<h2><small>".$row["name"]."</small></h2>";
    }
    ?>
<a class="btn btn-default" href="/index.php?page=port_traffic&switch=<?php echo $_GET["switch"]; ?>&time=3600" role="button">1 hour</a>
<a class="btn btn-default" href="/index.php?page=port_traffic&switch=<?php echo $_GET["switch"]; ?>&time=10800" role="button">3 hours</a>
<a class="btn btn-default" href="/index.php?page=port_traffic&switch=<?php echo $_GET["switch"]; ?>&time=21600" role="button">6 hours</a>
<br />
    <?php

  $sql = "SELECT ports.id,switches.name,ports.ifName FROM ports JOIN switches WHERE ports.switch_id = switches.id AND switches.id = '".$_GET["switch"]."' ORDER BY ports.ifIndex";
  $result = mysqli_query($con,$sql);
  $found = false;
    while($row = mysqli_fetch_array($result))
    {
      echo '<div class="col-md-6"> <img class="img-responsive" src="/graph/make_port_graph.php?port='.$row["id"].'&time='.$time.'" alt="'.$row["name"]." - ".$row["ifName"].'"></div>';
      $found = true;
    }
if($found == false) {
  echo "No ports found, if the switch is just added, wait...";
}
}

?>
