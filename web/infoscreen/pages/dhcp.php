<h1 class="text-light-grey text-center">DHCP STATUS </h1>
<?php
include("../database.php");

function mask2cidr($mask){
  $long = ip2long($mask);
  $base = ip2long('255.255.255.255');
  return 32-log(($long ^ $base)+1,2);
}

function cidrToRange($cidr) {
  return $ip_count = 1 << (32 - $cidr);
}

#Grap all the networks
$sql = "SELECT * FROM netlist WHERE in_use = 1";

echo '<div class="text-center column-1"><div class="row">';
$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    $color = "background-dark";
    if($row["dhcp"]) {
    $last_dhcp_timestamp = strtotime($row["last_dhcp_request"]);
    $date = new DateTime();
    $current = $date->getTimestamp();
    $green = $current - 900;
    $yellow = $current - 1800;

if($last_dhcp_timestamp >= $green) {
  $color = "background-light";
}elseif($last_dhcp_timestamp >= $yellow) {
  $color = "background-warning";
} else {
  $color = "background-error";
}
}
    ?>
<div class="column-1-2"> <p class="<?php echo $color; ?>"><?php echo $row["name"]; ?>(<?php echo $row["network"]; ?>) <br/>Last dhcp req: <?php echo $row["last_dhcp_request"]; ?> </p></div>
    <?php
}
echo "</div> </div>";
