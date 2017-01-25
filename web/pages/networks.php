<?php
include("database.php");

function mask2cidr($mask){
  $long = ip2long($mask);
  $base = ip2long('255.255.255.255');
  return 32-log(($long ^ $base)+1,2);
}

function cidrToRange($cidr) {
  return $ip_count = 1 << (32 - $cidr);
}

if(@$_GET["network"] == "") {

#Grap all the networks
$sql = "SELECT * FROM netlist WHERE in_use = 1";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    $color = "info";
    if($row["dhcp"]) {
    $last_dhcp_timestamp = strtotime($row["last_dhcp_request"]);
    $date = new DateTime();
    $current = $date->getTimestamp();
    $green = $current - 900;
    $yellow = $current - 1800;

if($last_dhcp_timestamp >= $green) {
  $color = "success";
}elseif($last_dhcp_timestamp >= $yellow) {
  $color = "warning";
} else {
  $color = "danger";
}
}
?>
<a href="/index.php?page=networks&network=<?php echo $row["id"] ?>">
<div class="list-group col-md-2">
  <div class="panel panel-default">
  <div class="panel-heading"><?php echo $row["name"]." - ".$row["network"]."/".mask2cidr($row["subnet"]); ?></div>
  <div class="panel-body">
    <div class="panel-body">
      <div class="alert alert-<?php echo $color; ?>" role="alert"><?php
       if($color != "info")
       { if($row["last_dhcp_request"] == null or $row["last_dhcp_request"] == 0)
         {echo "Error: No dhcp ack found";} else {echo "Last dhcp ack <br> ".$row["last_dhcp_request"];} } else {
           echo "No dhcp here";
         }
 ?></div>
      <?php if($row["dhcp"] == 1 AND ($row["last_dhcp_request"] != null or $row["last_dhcp_request"] != 0)) {
        //Calculate dhcp lease size
        $total = cidrToRange(mask2cidr($row["subnet"]));
        $total = $total-3; #Remove id,router,broadcast.
        $total = $total-$row["dhcp_reserved"]; #Remove reserved
        //Get all the leases for this network
        $sql2 = "SELECT a.id FROM dhcp_leases a WHERE network = '".$row["id"]."'";
        $result2 = mysqli_query($con,$sql2);
        $number = mysqli_num_rows($result2)
        ?>
      <div class="progress">
  <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="<?php echo $number; ?>" aria-valuemin="0" aria-valuemax="<?php echo $total; ?>" style="width: <?php echo 100/$total*$number; ?>%; min-width: 3em;">
    <?php echo $number."/".$total; ?>
  </div>
</div>
<?php }?>
    </div>
  </div>
</div>
</div>
</a>

<?php
}
}
else {
  #Grap the network

  $sql = "SELECT * FROM netlist WHERE id = '".$_GET["network"]."'";

  $result = mysqli_query($con,$sql);
    while($row = mysqli_fetch_array($result))
    {
      echo "<h2> ".$row["name"]."<small> ".$row["network"]."/".mask2cidr($row["subnet"])." - ".$row["desc"] ."</h2>";
      if($row["dhcp"]) {
        $start_time = (time() - 3600 * 3) * 1000;
        $end_time = time() * 1000;
        echo'<iframe src="http://lcs.area.sdok.no:3000/dashboard-solo/db/dhcp-leases?var-network='.$row["name"].'&panelId=1&theme=light&from='.$start_time.'&to='.$end_time.'" width="100%" height="400" frameborder="0"></iframe>';
      echo "<br/>";
    }
    echo '<table class="table table-striped table-bordered table-hover">';
    if($row["dhcp"]) {
      echo '<tr> <td class="col-md-2"> DHCP:</td><td> <span class="glyphicon glyphicon-ok" aria-hidden="true"></span> </td> </tr>';
      echo '<tr> <td class="col-md-2"> DHCP-reserved:</td><td>'.$row["dhcp_reserved"].'</td> </tr>';
    } else {
    echo '<tr> <td class="col-md-2"> DHCP:</td><td> <span class="glyphicon glyphicon-remove" aria-hidden="true"></span> </td> </tr>';
    }
    echo '<tr> <td class="col-md-2"> VLAN:</td><td> '.$row["vlan"].' </td> </tr>';
    echo '</table>';
  }
}
