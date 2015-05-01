<?php
class sidebar{

public $pages = [
    "switchmap" => "switches",
    "switches" => "switches",
    "port_traffic" => "switches",
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
