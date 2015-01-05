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
  echo '<table border="0" cellpadding="0" cellspacing="0">';
    $ledige = 0;
    $rad = 0;
    $plass_rad = 0;
    $lines = explode("z", $map);
    foreach ($lines as $value) {
      echo "<tr>\n";
        //Rad
        $x = 0;
        $y = 0;

        $y++;
        $rad++;
        $new_rad = true;
        $sete = 0;
        $block[$rad] = str_split($value);
        foreach ($block[$rad] as $thing) {
          if($thing == "A") {
            $plass_rad++;
            $sete = 0;
          }

          if($thing == "O") {
            ?>
            <td id="<?php echo $plass_rad.".".$sete; ?>" class="empty"> </td>
            <?php
          }
          elseif($thing == "X") {
            if($new_rad) {
              $new_rad = false;
              $plass_rad++;
            }
            $sete++;
            $ledige++;
            if(@$switches[$plass_rad][$sete] != NULL) {
              //Get the switch name and model
              $switch_id = $switches[$plass_rad][$sete];
              $sql = "SELECT `name`,`model`,`distro_id`,`distro_port` FROM `switches` WHERE `id` = $switch_id";
              $result = mysqli_query($con,$sql);
              while($row = mysqli_fetch_array($result))
              {
                $switch_name = $row["name"];
                $switch_model = $row["model"];
                $switch_port = $row["distro_id"].":".$row["distro_port"];
              }

              ?>
              <td id="<?php echo $plass_rad.".".$sete; ?>" class="kantswitch" onmouseover="tooltip.show('<strong><?php echo $switch_name ?></strong> <br /> <?php echo $switch_model."<br /> ".$switch_port; ?> ');" onmouseout="tooltip.hide();"></td>
              <?php
            }
              else {
            ?>
            <td id="<?php echo $plass_rad.".".$sete; ?>" class="white"></td>
            <?php
          }
              }
          elseif($thing == "S") {
            ?>
            <td class="stage" onmouseover="tooltip.show('<strong>Scene</strong>');" onmouseout="tooltip.hide();"></td>
            <?php
          }
          elseif($thing == "K") {
            ?>
            <td class="kiosk" onmouseover="tooltip.show('<strong>Kiosk</strong>');" onmouseout="tooltip.hide();"></td>
            <?php
          }
          elseif($thing == "U") {
            ?>
            <td class="utgang" onmouseover="tooltip.show('<strong>Inngang/Utgang</strong>');" onmouseout="tooltip.hide();"></td>
            <?php
          }
          elseif($thing == "C") {
            ?>
            <td class="crew" onmouseover="tooltip.show('<strong>Crew</strong>');" onmouseout="tooltip.hide();"></td>
            <?php
          }
          elseif($thing == "R") {
            if($new_rad) {
              $new_rad = false;
              $plass_rad++;
            }
            $sete++;
            ?>
            <td id="" class="red" onmouseover="tooltip.show('<strong> Reservert</strong>');" onmouseout="tooltip.hide();"></td>
            <?php
          }
        }
        echo "</tr>\n";
      }
      echo '</table> ';
      ?>
    </body>
    </html>
