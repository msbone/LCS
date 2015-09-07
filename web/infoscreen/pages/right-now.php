<?php
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

// SELECT SUM(  `current_in` ) , SUM(  `current_out` ) FROM  `ports`
include("../database.php");

$sql = "SELECT SUM(  current_in ) AS inn , SUM(  current_out ) AS ut FROM  ports";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    echo '<h1 class="text-light-grey text-center">Totalt traffic right now <br /> <small style="font-size: 80px;" class="text-light-grey">';
echo "".bytesToSize($row["inn"] + $row["ut"]) . "/s </small> <br />";
}
echo "<img class='responsive' src='/graph/all_traffic.php?big=1&rnd=".time()."'>";
?>
