<h1 class="text-light-grey text-center">Top 5 ports </h1>
  <table class="table-bordered table-block text-light-grey">
    <thead>
      <tr>
      <th>Switch</th>
      <th>Port</th>
      <th>In</th>
      <th>Out</th>
      <th>Total</th>
      </tr>
</thead>
<?php
/**
 * Convert bytes to human readable format
 *
 * @param integer bytes Size in bytes to convert
 * @return string
 */
function bytesToSize($bytes, $precision = 1)
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

include("../database.php");
$sql = "SELECT switches.name, ports.ifName,switches.id AS swid, ports.id AS ifid, ports.current_in, ports.current_out, (ports.current_in + ports.current_out) AS total FROM ports JOIN switches WHERE ports.switch_id = switches.id ORDER BY total DESC LIMIT 5";
$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  { ?>
    <tbody>
<tr>
    <td><?php echo $row["name"]; ?></td>
  <td><?php echo $row["ifName"]; ?></td>
  <td><?php echo bytesToSize($row["current_in"]); ?>/s</td>
  <td><?php echo bytesToSize($row["current_out"]); ?>/s</td>
  <td><?php echo bytesToSize($row["total"]); ?>/s</td>
</tr>
<?php } ?>
  </table>
