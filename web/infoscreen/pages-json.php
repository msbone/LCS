<?php

 $return_arr = array();

   #$return_arr[] =  "switchmap"; #THE JS HERE IS NOT GOOD, NEVER USE IN INFOSCREEN. IT WILL KILL
   $return_arr[] =  "right-now";
   $return_arr[] =  "internet-traffic";
   $return_arr[] =  "top-5";
   #$return_arr[] =  "sharptickets";
   #$return_arr[] =  "webcam";


header('Content-Type: application/json');
echo json_encode(array("pages" => $return_arr));
