<?php
session_start();

//Henter ut "mapen" fra seatmap.txt (this is at install graped from sharptickets)
$map = file_get_contents("seatmap.txt");

?>
<!doctype html>
<html>
<head>
  <script type="text/javascript">
  $(document).ready(function() {
    $("td").click(function () {
      jQuery.post("/place_switches/functions.php", {seat: $(this).attr("id") },
      function(data){
        $('#salkart').load('/place_switches/draw.php' + "&amp;" + Math.random()*99999 );
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
            <td class="empty"> </td>
            <?php
          }
          elseif($thing == "X") {
            if($new_rad) {
              $new_rad = false;
              $plass_rad++;
            }
            $sete++;
            $ledige++;
                ?>
                <td id="<?php echo $plass_rad.".".$sete; ?>" class="red" onmouseover="tooltip.show('<strong> <?php echo $nick; ?></strong> <br /> <?php echo "Rad ".$plass_rad."<br /> Sete ".$sete; ?>');" onmouseout="tooltip.hide();"></td>
                <?php
              }
            }
            else {
              ?>
              <td id="<?php echo $plass_rad.".".$sete; ?>" class="white" onmouseover="tooltip.show('<strong>Ledig Sete</strong> <br /> <?php echo "Rad ".$plass_rad."<br /> Sete ".$sete; ?> ');" onmouseout="tooltip.hide();"></td>
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
