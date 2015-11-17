<?php

 $return_arr = array();

   $return_arr[] =  "switchmap";
   $return_arr[] =  "speedmap";
   $return_arr[] =  "right-now";
   $return_arr[] =  "internet-traffic";
   $return_arr[] =  "top-5";
   #$return_arr[] =  "sharptickets";
   $return_arr[] =  "webcam";
   $return_arr[] =  "dhcp";


header('Content-Type: application/json');
echo json_encode(array("pages" => $return_arr));
