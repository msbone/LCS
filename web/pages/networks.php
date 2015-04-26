<?php
include("database.php");

function mask2cidr($mask){
  $long = ip2long($mask);
  $base = ip2long('255.255.255.255');
  return 32-log(($long ^ $base)+1,2);

  /* xor-ing will give you the inverse mask,
      log base 2 of that +1 will return the number
      of bits that are off in the mask and subtracting
      from 32 gets you the cidr notation */

}

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
      <?php if($row["dhcp"] == 1) { ?>
      <div class="progress">
  <div class="progress-bar progress-bar-success" role="progressbar" aria-valuenow="10" aria-valuemin="0" aria-valuemax="100" style="width: 10%; min-width: 3em;">
    10%
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
