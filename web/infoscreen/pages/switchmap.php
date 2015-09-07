<?php
#THE JS HERE IS NOT GOOD, NEVER USE IN INFOSCREEN. IT WILL KILL

if($_GET["show"] != "1") {
?>
<iframe height="1000px" width="100%" src="./pages/switchmap.php?show=1"></iframe>
<?php

} else{
?>
<link rel="stylesheet" href="/render/render.css">

<center>
<div class="container-fluid">
<p id="playground">
 <img src="/render/vlan15.png" alt="" id="map" />
</p>
<script>
 // These are used by ping.js, below.
 var switches_url = "/render/switches-json.php";
 var ping_url = "/render/ping-json.php";
 var draw_linknets = false;
 var can_edit = false;
</script>
<script type="text/javascript" src="/render/render.js"></script>
</div>
</center>
<?php
}
 ?>
