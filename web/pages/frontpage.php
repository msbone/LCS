<h4> Welcome to LCS (LAN CONFIG/CONTROL SYSTEM) </h4>
<div class="row">
  <div class="col-md-7">
    <div class="well well-sm">
      <h5><strong> Top 10 ports in network</strong> </h5>
<div class="table-responsive">
  <table class="table table-bordered">
    <tr>
      <th>Port</th>
      <th>Switch</th>
      <th>Bytes in per sec</th>
      <th>Bytes out per sec</th>
</tr>
<?php
/**
 * Convert bytes to human readable format
 *
 * @param integer bytes Size in bytes to convert
 * @return string
 */
function bytesToSize($bytes, $precision = 2)
{
    $kilobyte = 1024;
    $megabyte = $kilobyte * 1024;
    $gigabyte = $megabyte * 1024;
    $terabyte = $gigabyte * 1024;

    if (($bytes >= 0) && ($bytes < $kilobyte)) {
        return $bytes . ' B';

    } elseif (($bytes >= $kilobyte) && ($bytes < $megabyte)) {
        return round($bytes / $kilobyte, $precision) . ' KB';

    } elseif (($bytes >= $megabyte) && ($bytes < $gigabyte)) {
        return round($bytes / $megabyte, $precision) . ' MB';

    } elseif (($bytes >= $gigabyte) && ($bytes < $terabyte)) {
        return round($bytes / $gigabyte, $precision) . ' GB';

    } elseif ($bytes >= $terabyte) {
        return round($bytes / $terabyte, $precision) . ' TB';
    } else {
        return $bytes . ' B';
    }
}

include("database.php");
$sql = "SELECT switches.name, ports.ifName, ports.current_in, ports.current_out, (ports.current_in + ports.current_out) AS total FROM ports JOIN switches WHERE ports.switch_id = switches.id ORDER BY total DESC LIMIT 10";
$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  { ?>
<tr>
  <td><?php echo $row["ifName"]; ?></td>
  <td><?php echo $row["name"]; ?></td>
  <td><?php echo bytesToSize($row["current_in"]); ?>/s</td>
  <td><?php echo bytesToSize($row["current_out"]); ?>/s</td>
</tr>
<?php } ?>
  </table>
</div></div></div>
  <div class="col-md-5"><div class="well well-sm"><img class="img-responsive" src="/rrd/dhcp-0-hour-2.png" alt="dhcp leases"></div><div class="well well-sm"><img class="img-responsive" src="/rrd/total-traffic-hour-2.png" alt="total traffic"></div></div>
</div>
