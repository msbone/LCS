<?php
include("database.php");

if(@$_GET["place"] != "") {
#Prøve å plassere switchen på kartet
$sql = "INSERT INTO placements (switch, x1, y1, x2, y2) VALUES ('".$_GET["place"]."','499','118','413','93')";
mysqli_query($con, $sql);
header("Location: /index.php?page=switchmap");
die();
}
 ?>
<link rel="stylesheet" href="/render/render.css">
<div class="container-fluid">
<p id="playground">
 <svg id="lines" width="1580" height="920" style="position: absolute; top: 0; left: 0; z-index: 1">
 </svg>
 <img src="/render/area15.png" alt="" id="map" />
</p>
<script>
 // These are used by ping.js, below.
 var switches_url = "/render/switches-json.php";
 var ping_url = "/render/traffic-json.php";
 var draw_linknets = false;
 var can_edit = false;
</script>
<script type="text/javascript" src="/render/render.js"></script>
</div>
