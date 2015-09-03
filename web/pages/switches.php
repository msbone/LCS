<?php
include("database.php");

 if(@$_GET["switch"] == null or @$_GET["switch"] == "") {
  #LIST ALL SWITCHES
  ?>
  <div class="table-responsive">
  <table class="table">
  <?php
  $sql =
  "SELECT a.id, a.name, a.model, a.ip, a.latency_ms FROM switches a  WHERE a.ip IS NOT NULL";
  echo '<tr class="info">';
  echo "<td><b>Name</b></td>";
  echo "<td><b>Model</b></td>";
  echo "<td><b>IP</b></td>";
  #echo "<td><b>Connected to</b></td>";
  echo "<td></td>";
  echo "</tr>";
  $result = mysqli_query($con,$sql);
    while($row = mysqli_fetch_array($result))
    {
      if($row["latency_ms"] != null) {
      echo '<tr class="success">';
    }
    else {
      echo '<tr class="danger">';
    }
      echo "<td>".$row["name"]."</td>";
      echo "<td>".$row["model"]."</td>";
      echo "<td>".$row["ip"]."</td>";
      #echo "<td>".$row["corename"].":".$row["distro_port"]."</td>";
      echo "<td><a href='/index.php?page=port_traffic&switch=".$row["id"]."'>Port stats</a></td>";
      echo "</tr>";
    }
    ?>
  </table>
 </div>
    <?php
}
else {
  echo "EHM 404";
}
