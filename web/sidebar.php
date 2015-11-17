<?php
class sidebar{

public $pages = [
    "switchmap" => "switches",
    "trafficmap" => "switches",
    "switches" => "switches",
    "port_traffic" => "switches",
    "networks" => "networks",
    "master_network" => "networks",
];

function render(){

    foreach ($this->pages as $key => $value) {
      if(@$_GET["page"] == $key) {
      include("pages/$value-sidebar.php");
      return;
    }
}

}
}
?>
