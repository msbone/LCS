<?php
$port_id = 4;

function bytesToSize($bytes, $precision = 2)
{
    $kilobyte = 1024;
    $megabyte = $kilobyte * 1024;
    $gigabyte = $megabyte * 1024;
    $terabyte = $gigabyte * 1024;

    if (($bytes >= 0) && ($bytes < $kilobyte)) {
        return $bytes . ' b';

    } elseif (($bytes >= $kilobyte) && ($bytes < $megabyte)) {
        return round($bytes / $kilobyte, $precision) . ' Kb';

    } elseif (($bytes >= $megabyte) && ($bytes < $gigabyte)) {
        return round($bytes / $megabyte, $precision) . ' Mb';

    } elseif (($bytes >= $gigabyte) && ($bytes < $terabyte)) {
        return round($bytes / $gigabyte, $precision) . ' Gb';

    } elseif ($bytes >= $terabyte) {
        return round($bytes / $terabyte, $precision) . ' Tb';
    } else {
        return $bytes . ' B';
    }
}

// SELECT SUM(  `current_in` ) , SUM(  `current_out` ) FROM  `ports`
include("../database.php");

$sql = "SELECT SUM(  current_in ) AS inn , SUM(  current_out ) AS ut FROM  ports WHERE id = $port_id";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    echo '<h1 class="text-light-grey text-center">Internet traffic <br /> <small class="text-light-grey">';
echo "In: ".bytesToSize($row["inn"]*8) . "/s<br />";
echo "Out: ".bytesToSize($row["ut"]*8) . "/s </small> </h1>";
echo "<img class='responsive' src='/graph/make_port_graph.php?big=1&port=$port_id'&rnd=".time().">";
}




?>
