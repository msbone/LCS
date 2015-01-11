<?php
//PARTS OF THIS CODE IS COPYRIGHTED BY SHARPTICKETS www.sharptickets.net
session_start();
include("../database.php");

//Henter ut "mapen" fra seatmap.txt (den blir hente ifra sharptickets.net ved første gang oppstart av lcs)
$map = file_get_contents("seatmap.txt");

#Grap all the switches and put them in an array
$sql = "SELECT `id`,`placement` FROM `switches` WHERE `placement` IS NOT NULL";

$result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
  #The switch placement is in RAD,SETE
   $placement = explode("/",$row["placement"]);

  $switches[$placement[0]][$placement[1]] = $row["id"];
}

$sql = "SELECT `id`,`placement` FROM `coreswitches` WHERE `placement` IS NOT NULL";

$result = mysqli_query($con,$sql);
while($row = mysqli_fetch_array($result))
{
  #The switch placement is in RAD,SETE
  $placement = explode("/",$row["placement"]);

  $cores[$placement[0]][$placement[1]] = $row["id"];
}

?>
<!doctype html>
<html>
<head>
  <script type="text/javascript">
  $(document).ready(function() {
    $("td").click(function () {
      $('#sidebar').load('/place_switches/sidebar.php?id=' + $(this).attr("id"));
      jQuery.post("/place_switches/functions.php", {seat: $(this).attr("id") },
      function(data){
        $('#salkart').load('/place_switches/draw.php');
      }
      );
    });
  });
</script>
<meta charset="utf-8">
</head>

<body>
  <?php
  $x = 0;
  $y = 0;

  echo '<table border="0" cellpadding="0" cellspacing="0">';
    $lines = explode("z", $map);
    foreach ($lines as $value) {
      echo "<tr>\n";
        //Rad


        $y++;
        $x = 0;

        $new_rad = true;
        $sete = 0;
        $block[$y] = str_split($value);
        foreach ($block[$y] as $thing) {


          if(@$cores[$x][$y] != NULL) {
            //Get the switch name and model
            $core_id = $cores[$x][$y];
            $sql = "SELECT `name` FROM `coreswitches` WHERE `id` = $core_id";
            $result = mysqli_query($con,$sql);
            while($row = mysqli_fetch_array($result))
            {
              $core_name = $row["name"];
              ?>
              <td id="<?php echo $x.".".$y; ?>" class="coreswitch" onmouseover="tooltip.show('<strong><?php echo $core_name; ?></strong>');" onmouseout="tooltip.hide();"></td>
              <?php
            }
            $x++;
          }

          elseif(@$switches[$x][$y] != NULL) {

            //Get the switch name and model
            $switch_id = $switches[$x][$y];
            $sql = "SELECT `name`,`model`,`distro_id`,`distro_port` FROM `switches` WHERE `id` = $switch_id";
            $result = mysqli_query($con,$sql);
            while($row = mysqli_fetch_array($result))
            {
              $switch_name = $row["name"];
              ?>
              <td id="<?php echo $x.".".$y; ?>" class="kantswitch" onmouseover="tooltip.show('<strong><?php echo $switch_name; ?></strong>');" onmouseout="tooltip.hide();"></td>
              <?php
            }
            $x++;
}
          elseif($thing == "O") {
            $x++;
            ?>
            <td id="<?php echo $x.".".$y; ?>" class="white" onmouseover="tooltip.show('<?php echo $x." ".$y; ?>');" onmouseout="tooltip.hide();"> </td>
            <?php
          }
          elseif($thing == "X") {
            $x++;
            ?>
            <td id="<?php echo $x.".".$y; ?>" class="white" onmouseover="tooltip.show('<?php echo $x." ".$y; ?>');" onmouseout="tooltip.hide();">X</td>
            <?php
              }
          elseif($thing == "S") {
            $x++;
            ?>
            <td id="<?php echo $x.".".$y; ?>" class="stage" onmouseover="tooltip.show('<strong>Scene</strong>');" onmouseout="tooltip.hide();"></td>
            <?php
          }
          elseif($thing == "U") {
            $x++;
            ?>
            <td id="<?php echo $x.".".$y; ?>" class="utgang" onmouseover="tooltip.show('<strong>Inngang/Utgang</strong>');" onmouseout="tooltip.hide();"></td>
            <?php
          }
          elseif($thing == "C") {
            $x++;
            ?>
            <td id="<?php echo $x.".".$y; ?>" class="crew" onmouseover="tooltip.show('<strong>Crew</strong>');" onmouseout="tooltip.hide();"></td>
            <?php
          }
        }
        echo "</tr>\n";
      }
      echo '</table> ';
      ?>
    </body>
    </html>
