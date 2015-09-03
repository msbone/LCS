<style>
.box {
  width: 30px;
  height: 30px;
  text-align: center;
  font-size: small;
}
table, th, td {
    border: 1px solid black;
}
</style>

<script>
$(document).ready(function(){
    $('[data-toggle="tooltip"]').tooltip();
});
</script>

<?php
include("database.php");

/**
 * Check if a given ip is in a network
 * @param  string $ip    IP to check in IPV4 format eg. 127.0.0.1
 * @param  string $range IP/CIDR netmask eg. 127.0.0.0/24, also 127.0.0.1 is accepted and /32 assumed
 * @return boolean true if the ip is in this range / false if not.
 */
function ip_in_range( $ip, $range ) {
	if ( strpos( $range, '/' ) == false ) {
		$range .= '/32';
	}
	// $range is in IP/CIDR format eg 127.0.0.1/24
	list( $range, $netmask ) = explode( '/', $range, 2 );
	$range_decimal = ip2long( $range );
	$ip_decimal = ip2long( $ip );
	$wildcard_decimal = pow( 2, ( 32 - $netmask ) ) - 1;
	$netmask_decimal = ~ $wildcard_decimal;
	return ( ( $ip_decimal & $netmask_decimal ) == ( $range_decimal & $netmask_decimal ) );
}

function mask2cidr($mask){
  $long = ip2long($mask);
  $base = ip2long('255.255.255.255');
  return 32-log(($long ^ $base)+1,2);
}

function cidrToRange($cidr) {
  return $ip_count = 1 << (32 - $cidr);
}

$net_array = array();
$sql = "SELECT network, subnet, name FROM netlist WHERE in_use = 1";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
  $net_array[] = $row["network"]."/".mask2cidr($row["subnet"]);
  $name_array[$row["network"]."/".mask2cidr($row["subnet"])] = $row["name"];
  }

$sql = "SELECT network FROM link_networks";

$result = mysqli_query($con,$sql);
    while($row = mysqli_fetch_array($result))
    {
    $net_array[] = $row["network"]."/30";
    $name_array[$row["network"]."/30"] = "LINK NETWORK";
    }

$sql = "SELECT ip, name FROM switches";

  $result = mysqli_query($con,$sql);
      while($row = mysqli_fetch_array($result))
      {
      $net_array[] = $row["ip"]."/32";
      $name_array[$row["ip"]."/32"] = $row["name"];
      }


#Grap all the Master networks
$sql = "SELECT * FROM netlist WHERE master = 1";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {

$ip_array = array();

    $first_4 = explode(".", $row["network"], 4);

    echo "<h3>".$row["name"]."<small> ".$row["network"]."/".mask2cidr($row["subnet"])."</small></h3>";
    $total = cidrToRange(mask2cidr($row["subnet"])) - 1;

    $row_count = 0;
    $ip_count = $first_4[3];
    $subnet_grow = 0;
    for ($z = 0; $z <= $total; $z++) {
//CHECK IF IP IN USE

$_1 = $first_4[0];
$_2 = $first_4[1];
$_3 = $first_4[2] + $subnet_grow;

$full_ip = $_1.".".$_2.".".$_3.".".$ip_count;

foreach ($net_array as $value1) {
    if(ip_in_range( $full_ip, $value1)) {
//IP IN USE
$ip_array[$full_ip] = true;
$name_array2[$full_ip] = $name_array[$value1];

    } else {
//IP FREE
if(!isset($ip_array[$full_ip])) {
  $ip_array[$full_ip] = false;
}
    }
}


$ip_count++;
if($ip_count == 256) {
  $subnet_grow++;
  $ip_count = 0;
}
    }

echo "<table class='.table .table-condensed '>";
$x = 0;
    foreach ($ip_array as $key => $value) {

      $explode_key = explode(".",$key,4);

      $x++;
      if($x == 1) {
        echo "<tr>";
      }
      if($value == 1) {
        echo "<td style='background-color: #39CCCC' class='box' data-toggle='tooltip' data-placement='left' title='$key | $name_array2[$key]'>".$explode_key[3]."</td>";
      } else {
        echo "<td style='background-color: white' class='box'>".$explode_key[3]."</td>";
      }

      if($x == 25) {
        echo "</tr>";
        $x = 0;
      }

}
echo "</table>";
  }

?>
