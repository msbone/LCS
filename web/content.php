<?php
class content{

public $pages = [
    "frontpage" => "Dashboard",
    "switches" => "Switches",
    "networks" => "Networks",
    "syslog" => "Syslog",
];

public $hidden_pages = [
    "port_traffic" => "Port Traffic",
    "switchmap" => "Switch Map",
    "trafficmap" => "Traffic Map",
    "master_network" => "Master Networks",
    "switches-create" => "Add new switch",
];

function render(){

    foreach ($this->pages as $key => $value) {
      if(@$_GET["page"] == $key) {
      include("pages/$key.php");
      return;
    }
}
foreach ($this->hidden_pages as $key => $value) {
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
foreach ($this->hidden_pages as $key => $value) {
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
}}}

function get_page_header() {
  foreach ($this->pages as $key => $value) {
    if(@$_GET["page"] == $key) {
    return $value;
  }
}
foreach ($this->hidden_pages as $key => $value) {
  if(@$_GET["page"] == $key) {
  return $value;
}
}
  return "Dashboard";
}

}
?>
