<?php
class sidebar{

public $pages = [
    "switchmap" => "Switchmap",
];

function render(){

    foreach ($this->pages as $key => $value) {
      if(@$_GET["page"] == $key) {
      include("pages/$key-sidebar.php");
      return;
    }
}

}
}
?>
