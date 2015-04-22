<?php
class content{

public $pages = [
    "frontpage" => "Dashboard",
    "switchmap" => "Switchmap",
    "configure" => "Configure",
];

function render(){

    foreach ($this->pages as $key => $value) {
      if(@$_GET["page"] == $key) {
      include("pages/$key.php");
      exit;
    }
}
include("pages/frontpage.php");

}

function get_page_name() {
  foreach ($this->pages as $key => $value) {
    if(@$_GET["page"] == $key) {
    return $value;
    exit;
  }
}
  return "Dashboard";
}

function render_menu() {
  foreach ($this->pages as $key => $value) {
    if(@$_GET["page"] == $key) {
    echo '<li class="active"><a href="\index.php?page='.$key.'">'.$value.'</a></li>';
  }
  else {
    echo '<li><a href="\index.php?page='.$key.'">'.$value.'</a></li>';
  }
}

}
}
?>
