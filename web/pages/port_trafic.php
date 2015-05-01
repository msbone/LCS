<?php
include("database.php");

if(@$_GET["switch"] == null or @$_GET["switch"] == "") {
  #LIST ALL SWITCHES
  ?>
  <div class="table-responsive">
  <table class="table table-striped">
  <?php
  $sql = "SELECT * FROM switches WHERE ip IS NOT NULL";
  echo "<tr>";
  echo "<td><b>Name</b></td>";
  echo "<td><b>Model</b></td>";
  echo "<td><b>IP</b></td>";
  echo "<td><b>SW/GW</b></td>";
  echo "<td><b>Ports</b></td>";
  echo "</tr>";
  $result = mysqli_query($con,$sql);
    while($row = mysqli_fetch_array($result))
    {
      echo "<tr>";
      echo "<td>".$row["name"]."</td>";
      echo "<td>".$row["model"]."</td>";
      echo "<td>".$row["ip"]."</td>";
      echo "<td>".$row["type"]."</td>";
      echo "<td><a href='/index.php?page=port_trafic&switch=".$row["id"]."'>".$row["type"]."</a></td>";
      echo "</tr>";
    }
    ?>
  </table>
 </div>
    <?php
} else if (@$_GET["port"] == null or @$_GET["port"] == "") {
  #LIST ALL PORTS ON SWITCH, WITH DAY GRAPH
  $sql = "SELECT ports.id,switches.name,ports.ifName FROM ports JOIN switches WHERE ports.switch_id = switches.id AND switches.id = '".$_GET["switch"]."' ORDER BY LENGTH(ports.ifName), ports.ifName";
  $result = mysqli_query($con,$sql);
    while($row = mysqli_fetch_array($result))
    {
      echo '<img src="/rrd/'.$row["id"].'-hour.png" alt="'.$row["name"]." - ".$row["ifName"].'">';
    }

} else {
  #LIST ALL GRAPH ON THAT PORT

}

?>
