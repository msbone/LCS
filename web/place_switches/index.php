<?php
//We use some of the salkart logic from sharptickets, this code is licensed for sharptickets.
?>
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js"></script>
  <link href="seatmap.css" rel="stylesheet" type="text/css">
  <script type="text/javascript" src="script.js"></script>
  <script type="text/javascript">
  $(document).ready(function() {
    $('#salkart').load('draw.php');
  });
  </script>
  <div id="salkart"> </div>
  <div id="sidebar">Velg en switch eller opprett en ny</div>
