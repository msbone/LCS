<?php
include("database.php");

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if(@$_POST["inputName"] == "") {
      $error["name"] = true;
    }
    if(@$_POST["inputModel"] == "") {
      $error["model"] = true;
    }
    if(@$_POST["inputDesc"] == "") {
      $error["desc"] = true;
    }
    if(@$_POST["inputSNMP"] == "") {
      $error["snmp"] = true;
    }
    if(@$_POST["inputNR"] == "") {
      $error["nr"] = true;
    }
    if(!isset($error)) {
      //Lets push everything to database!

    if($_POST["inputNR"] == 1) {
    //One
    mysqli_query($con,"INSERT INTO switches (`name`,`model`,`desc`,`ip`,`snmp_version`,`net_id`)
VALUES ('".$_POST["inputName"]."','".$_POST["inputModel"]."','".$_POST["inputDesc"]."','".$_POST["inputIP"]."','".$_POST["inputSNMP"]."','".$_POST["inputNET"]."')") or die(mysqli_error($con));
die("Created");
  } else {
    //More then 1
    for ($x = 1; $x <= $_POST["inputNR"]; $x++) {
    $name = $_POST["inputName"] .$x;
$exploded_ip = explode(".",$_POST["inputIP"]);
$last_int = $exploded_ip[3] + $x - 1;
$ip = $exploded_ip[0].".".$exploded_ip[1].".".$exploded_ip[2].".".$last_int;

mysqli_query($con,"INSERT INTO switches (`name`,`model`,`desc`,`ip`,`snmp_version`,`net_id`)
VALUES ('".$name."','".$_POST["inputModel"]."','".$_POST["inputDesc"]."','".$ip."','".$_POST["inputSNMP"]."','".$_POST["inputNET"]."')") or die(mysqli_error($con));
}
die("Created");




  }
    }
}

?>
<form class="form-horizontal" action="" method="post">
  <div class="form-group <?php if(@$error["name"]) {echo "has-error";} ?>">
    <label for="inputName" class="col-sm-2 control-label">Name*</label>
    <div class="col-sm-10">
      <input type="text" class="form-control" name="inputName" id="inputName" placeholder="Name" value="<?php echo @$_POST["inputName"]; ?>">
    </div>
  </div>
  <div class="form-group <?php if(@$error["model"]) {echo "has-error";} ?>">
    <label for="inputModel" class="col-sm-2 control-label">Model*</label>
    <div class="col-sm-10">
      <input type="text" class="form-control" name="inputModel" id="inputModel" placeholder="Model" value="<?php echo @$_POST["inputModel"]; ?>">
    </div>
  </div>
  <div class="form-group <?php if(@$error["desc"]) {echo "has-error";} ?>">
    <label for="inputDesc" class="col-sm-2 control-label">Desc*</label>
    <div class="col-sm-10">
      <input type="text" class="form-control" name="inputDesc" id="inputDesc" placeholder="Desc" value="<?php echo @$_POST["inputDesc"]; ?>">
    </div>
  </div>
  <div class="form-group">
    <label for="inputIP" class="col-sm-2 control-label">IP</label>
    <div class="col-sm-10">
      <input type="text" class="form-control" name="inputIP" id="inputIP" placeholder="IP">
    </div>
  </div>
  <div class="form-group">
    <label for="inputNET" class="col-sm-2 control-label">Net-ID</label>
    <div class="col-sm-10">
      <input type="text" class="form-control" name="inputNET" id="inputNET" placeholder="Net-ID">
    </div>
  </div>
  <div class="form-group <?php if(@$error["snmp"]) {echo "has-error";} ?>">
    <label for="inputSNMP" class="col-sm-2 control-label">SNMP-VERSION*</label>
    <div class="col-sm-10">
      <label class="radio-inline">
        <input type="radio" name="inputSNMP" id="inlineRadio" <?php if(@$_POST["inputSNMP"] == "2") {echo "checked='checked'";} ?> value="2"> 2
      </label>
      <label class="radio-inline">
        <input type="radio" name="inputSNMP" id="inlineRadio" <?php if(@$_POST["inputSNMP"] == "1") {echo "checked='checked'";} ?> value="1"> 1
      </label>
      <label class="radio-inline">
        <input type="radio" name="inputSNMP" id="inlineRadio" <?php if(@$_POST["inputSNMP"] == "null") {echo "checked='checked'";} ?> value="null"> Disabled
      </label>
    </div>
  </div>
  <div class="form-group <?php if(@$error["nr"]) {echo "has-error";} ?>">
    <label for="inputNR" class="col-sm-2 control-label">Number of switches*</label>
    <div class="col-sm-10">
      <input type="number" class="form-control" name="inputNR" id="inputNR" placeholder="Number of switches" value="<?php if(@$_POST["inputNR"] != "") {echo $_POST["inputNR"];} else {echo 1;} ?>">
    </div>
  </div>
  <div class="form-group">
    <div class="col-sm-offset-2 col-sm-10">
      <button type="submit" class="btn btn-default">Create</button>
    </div>
  </div>
</form>

When creating more then 1 switch, the system will add 1,2,3,4,... behind the name. It will also auto increment the IP
