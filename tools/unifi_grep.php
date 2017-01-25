<?php
include '/lcs/web/unifi/phpapi/class.unifi.php';
include '/lcs/web/unifi/config.php';

include("/lcs/web/database.php");

require '/lcs/web/vendor/autoload.php';

$site_id = 'default';

$unifidata        = new unifiapi($controlleruser, $controllerpassword, $controllerurl, $site_id, $controllerversion);
$unifidata->debug = $debug;
$loginresults     = $unifidata->login();
if($loginresults === 400) {die('Failed to login');}


$client = new InfluxDB\Client('localhost', 8086);
$influx = $client->selectDB('lcs');

#Get Access points
$sql = "SELECT * FROM aps";
$added_aps = 0;
$updated_aps = 0;

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    $aps[$row['unifi_id']] = $row['id'];
    $ap_mac[$row['mac']] = $row['id'];
    $ap_name[$row['mac']] = $row['name'];
  }

foreach ($unifidata->list_aps() as $key => $value) {

if(isset($aps[$value->_id])) {
//Exist, lets update


} else {
//Do not exist, lets create it
$sql2 = "INSERT INTO aps (unifi_id, ip, mac, name, model, version, last_seen)
VALUES ('".$value->_id."', '".$value->ip."', '".$value->mac."', '".$value->name."', '".$value->model."', '".$value->version."', '".$value->last_seen."')";

if ($con->query($sql2) === TRUE) {
    $added_aps++;
} else {
    echo "Error: " . $sql2 . "<br>" . $con->error ."\n";
}
}

$points = array(
    new InfluxDB\Point(
        'net_wifi',
        null,
        ['client' => $value->name, 'unifi_id' => $value->_id],
        ['rx_bytes' => $value->rx_bytes, 'tx_bytes' => $value->tx_bytes]
    )
  );
$result = $influx->writePoints($points);

}

#Get everything from ap_clients
$sql = "SELECT * FROM ap_clients";

  $added = 0;
  $updated = 0;

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    $ap_clients[$row['unifi_id']] = $row;
  }

foreach ($unifidata->list_clients() as $key => $value) {

if(isset($ap_clients[$value->_id])) {
  //Exist, lets update
  $ap_id = $ap_mac[$value->ap_mac];

  $sql2 = "UPDATE ap_clients SET mac='".$value->mac."', ip='".$value->ip."', hostname='".$value->hostname."', last_seen='".$value->last_seen."', first_seen='".$value->first_seen."',
  uptime='".$value->uptime."', user_id='".$value->user_id."',
  noise='".$value->noise."', radio_proto='".$value->radio_proto."', rssi='".$value->rssi."', signal_strength='".$value->signal."', channel='".$value->channel."', essid='".$value->essid."',
  assoc_time='".$value->assoc_time."', ap_mac='".$value->ap_mac."', ap_id='".$ap_id."'
   WHERE unifi_id='".$value->_id."'";

  if ($con->query($sql2) === TRUE) {
      $updated++;
  } else {
      echo "Error updating: " . $sql2 . "<br>" . $con->error ."\n";
  }

} else {

  //Do not exist, lets create it
  $sql2 = "INSERT INTO ap_clients (unifi_id, mac, ip, hostname, last_seen, first_seen, uptime, user_id, noise, radio_proto, rssi, signal_strength, channel, essid, assoc_time, ap_mac)
  VALUES ('".$value->_id."', '".$value->mac."', '".$value->ip."', '".$value->hostname."', '".$value->last_seen."', '".$value->first_seen."', '".$value->uptime."', '".$value->user_id."', '".$value->noise."',
  '".$value->radio_proto."', '".$value->rssi."','".$value->signal."', '".$value->channel."', '".$value->essid."', '".$value->assoc_time."', '".$value->ap_mac."')";

  if ($con->query($sql2) === TRUE) {
      $added++;
  } else {
      echo "Error: " . $sql2 . "<br>" . $con->error ."\n";
  }

}

//Lets count how many at each accesspoint

$ap_connected[$value->ap_mac]++;

$points = array(
    new InfluxDB\Point(
        'net_wifi',
        null,
        ['client' => $value->hostname, 'unifi_id' => $value->_id],
        ['rx_bytes' => $value->rx_bytes, 'tx_bytes' => $value->tx_bytes]
    )
  );
$result = $influx->writePoints($points);
}

foreach ($ap_connected as $key => $value) {

  $points = array(
      new InfluxDB\Point(
          'wifi_connected',
          null,
          ['ap' => $ap_name[$key], 'lcs_id' => $ap_mac[$key]],
          ['connected' => $value]
      )
    );
  $result = $influx->writePoints($points);

}

echo "Created aps: $added_aps \n";
echo "Updated aps: $updated_aps \n";

echo "Created: $added \n";
echo "Updated: $updated \n";

 ?>
