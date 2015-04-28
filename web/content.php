<?php
class content{

public $pages = [
    "frontpage" => "Dashboard",
    "switchmap" => "Switchmap",
    "networks" => "Networks",
    "configure" => "Configure",
];

function render(){

    foreach ($this->pages as $key => $value) {
      if(@$_GET["page"] == $key) {
      include("pages/$key.php");
      return;
    }
}
include("pages/frontpage.php");

}

function get_page_name() {
  foreach ($this->pages as $key => $value) {
    if(@$_GET["page"] == $key) {
    return $value;
  }
}
  return "Dashboard";
}

function render_menu() {
  foreach ($this->pages as $key => $value) {
    if(@$_GET["page"] == $key) {
    echo '<li class="active"><a href="/index.php?page='.$key.'">'.$value.'</a></li>';
  }
  elseif(@$_GET["page"] == "" AND $key == "frontpage") {
    echo '<li class="active"><a href="/index.php?page='.$key.'">'.$value.'</a></li>';
  }else {
echo '<li><a href="/index.php?page='.$key.'">'.$value.'</a></li>';
}
}

}
}
?>
