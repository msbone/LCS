<?php
echo '<h1 class="text-light-grey text-center">Sold tickets <br /> <small style="font-size: 80px;" class="text-light-grey">';
echo file_get_contents('http://api.sharptickets.net/?api=tickets_taken&event=18');
echo "</small>";

 ?>
