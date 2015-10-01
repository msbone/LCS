<?php
include("../database.php");
#print_r ($_GET["from"]);
#print_r ($_GET["type"]);
#print_r ($_GET["priority"]);

$page = $_GET["page"];
$start = 0;
for ($i=1; $i < $page ; $i++) {
  $start = $start + 30;
}


$from_q;
$type_q;
$priority_q;

foreach ($_GET["from"] as $value) {
      $from_q .= "'".$value."',";
}

foreach ($_GET["type"] as $value) {
      $type_q .= "'".$value."',";
}

foreach ($_GET["priority"] as $value) {
      $priority_q .= "'".$value."',";
}

$from_q = substr($from_q, 0, -1);
$type_q = substr($type_q, 0, -1);
$priority_q = substr($priority_q, 0, -1);

 ?>
 <div class="table-responsive">
 <table class="table">
 <tr class="info">
   <td><b>From</b></td>
   <td><b>Message</b></td>
   <td><b>Priority</b></td>
   <td><b>Time</b></td>
   </tr>
 <?php
  $sql = "SELECT * FROM syslog WHERE `from` IN ($from_q) AND `type` IN ($type_q) AND `priority` IN ($priority_q) ORDER BY time DESC, `type`, `from` LIMIT 30 OFFSET $start";
  #echo $sql;
 $result = mysqli_query($con,$sql);
   while($row = mysqli_fetch_array($result))
   {

     switch ($row["priority"]) {
       case '1':
         $priorityText = "Super high";
         break;
         case '2':
           $priorityText = "High";
           break;
           case '3':
             $priorityText = "Medium";
             break;
             case '4':
               $priorityText = "Low";
               break;
               case '5':
                 $priorityText = "Info";
                 break;
                 case '9':
                   $priorityText = "Debug";
                   break;
       default:
         # code...
         break;
     }

     if($row["priority"] <= 2) {
 echo '<tr class="danger">';
 }
 elseif($row["priority"] <= 4) {
echo '<tr class="warning">';
}
 else {
   echo '<tr class="">';
 }
 echo '<td>'.$row["from"]."</td>";
 echo '<td>'.$row["message"]."</td>";
 echo '<td>'.$priorityText."</td>";
 echo '<td>'. date("H:i:s", $row["time"])."</td>";
 echo '</tr>';
   }
  ?>
 </table>
 </div>
