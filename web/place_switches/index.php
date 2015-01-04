<?php
//We use some of the salkart logic from sharptickets, this code is licensed for sharptickets.
?>

  <link href="seatemap.css" rel="stylesheet" type="text/css">
  <script type="text/javascript" src="script.js"></script>
  <script type="text/javascript">
  $(document).ready(function() {
    $('#salkart').load('draw.php');
  });
  </script>
  <div id="salkart"> </div>
