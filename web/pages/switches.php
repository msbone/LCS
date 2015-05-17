<?php
include("database.php");
if(@$_GET["switch"] == "new") {
  ?>
  <form method="POST" autocomplete="off" action="/index.php?page=switches&switch=new">
    <div class="form-group">
      <label for="switch_name">Name</label>
      <input type="text" class="form-control" name="switch_name" id="switch_name" placeholder="Enter name" <?php echo 'value="'.@$_POST["switch_name"].'"'; ?>>
    </div>
    <?php if(@$_POST["switch_mode"] == "") { ?>
    <div class="form-group">
      <label for="switch_mode">Type</label>
      <select class="form-control" id="switch_mode" name="switch_mode">
  <option value="1">Egdeswitch (L2)</option>
  <option value="2">GSW (L2/L3)</option>
  <option value="3">SW (L2)</option>
</select>
    </div>
    <div class="form-group">
      <label for="switch_type">Switch</label>
      <select class="form-control" id="switch_type" name="switch_type">
  <option value="dgs1210">Dlink DGS-1210-24 </option>
  <option value="c3560">Cisco 3560G</option>
  <option value="ccr1009">Mikrotik CCR1009-8G-1S-1S+</option>
  <option value="other">Other</option>
  <option value="other-nosnmp">Other (NO-SNMP)</option>
</select>
    </div>
    <?php
  }else {
    ?>
    <div class="form-group">
      <label for="switch_mode">Mode</label>
      <input type="text" class="form-control" name="switch_mode" disabled id="switch_mode" <?php echo 'value="'.@$_POST["switch_mode"].'"'; ?>>
      <input type="hidden" name="switch_mode" <?php echo 'value="'.@$_POST["switch_mode"].'"'; ?> />
      <label for="switch_type">Switch</label>
      <input type="text" class="form-control" name="switch_type" disabled id="switch_type" <?php echo 'value="'.@$_POST["switch_type"].'"'; ?>>
      <input type="hidden" name="switch_type" <?php echo 'value="'.@$_POST["switch_type"].'"'; ?> />
    </div>
    <?php

  }
    if(@$_POST["switch_name"] != "") {
      #Vi forsetter videre
      #Om dette er en lag2 switch må vi velge hvilken core den er koblet i.
      if($_POST["switch_mode"] == 1 or $_POST["switch_mode"] == 3) {
        #Vi må da liste ut alle cores med ledige porter (MÅ TENKE LITT PÅ HVORDAN de_ports skal fungere)
        $sql = "SELECT id, name, de_ports from switches WHERE type = '2' AND de_ports IS NOT NULL";
?>
<?php if(@$_POST["switch_core"] == "") {?>
<div class="form-group">
  <label for="switch_type">Core</label>
  <select class="form-control" id="switch_core" name="switch_core">
<?php
        $result = mysqli_query($con,$sql);
        while($row = mysqli_fetch_array($result))
        {
          ?>
        <option value="<?php echo $row["id"]; ?>"><?php echo $row["name"]; ?> </option>
          <?php
        }
        ?>
      </select>
          </div>
          <?php }else {
            ?>
            <div class="form-group">
              <label for="switch_mode">Core</label>
              <input type="text" class="form-control" name="switch_core" disabled id="switch_core" <?php echo 'value="'.@$_POST["switch_core"].'"'; ?>>
              <input type="hidden" name="switch_core" <?php echo 'value="'.@$_POST["switch_core"].'"'; ?> />
            </div>
            <?php
          } ?>
          <div class="form-group">
            <label for="switch_uplink">Local uplink port</label>
            <input type="text" class="form-control" name="switch_uplink" id="switch_uplink" placeholder="g1 or ge0/1" <?php echo 'value="'.@$_POST["switch_uplink"].'"'; ?>>
          </div>
        <?php
      }
      if(@$_POST["switch_core"] != "") {
        #Vi forsetter videre
        #Hente ut nettverkslisten til den coren. Om vi ikke finner noe kan vi ikke gå videre
        $sql = "SELECT netlist.id, netlist.name, netlist.network, netlist.subnet, netlist.vlan from netlist WHERE in_use = '1' AND coreswitch = '".$_POST["switch_core"]."'";
        $result = mysqli_query($con,$sql);
        ?>
        <div class="form-group">
          <label for="switch_net">Network</label>
          <select class="form-control" id="switch_net" name="switch_net">
        <?php
        $irun = false;
        while($row = mysqli_fetch_array($result))
        {
          ?>
        <option value="<?php echo $row["id"]; ?>"><?php echo $row["name"]." - ".$row["network"]; ?> </option>
          <?php
          $irun = true;
        }
        ?>
      </select>
          </div>
          <?php
        if($irun == false) {
          echo "NO NETWORK FOUND!!!! KILL ME <br>";
          die();
        }
        ?>
        <div class="form-group">
          <label for="switch_connected">Port on core</label>
          <input type="text" class="form-control" name="switch_connected" id="switch_connected" placeholder="g1 or ge0/1" <?php echo 'value="'.@$_POST["switch_connected"].'"'; ?>>
        </div>
        <?php
        if(@$_POST["switch_net"] != "") {
          #JA, DA GAR VI VIDERE MOT SLUTTEN
          ?>
          <div class="form-group">
            <label for="switch_ip">IP</label>
            <input type="text" class="form-control" name="switch_ip" id="switch_ip" value="<?php echo exec("perl /lcs/tools/get_next_free.pl ".$_POST["switch_net"]); ?>">
          </div>
          <?php
        }
        if(@$_POST["switch_ip"] != "") {
          #LETS PUSH
          echo "DONE";
          $sql = "INSERT INTO switches (name, model, ip, net_id, type, uplink, distro_id, distro_port)
          VALUES ('".$_POST["switch_name"]."', '".$_POST["switch_type"]."','".$_POST["switch_ip"]."','".$_POST["switch_net"]."','".$_POST["switch_mode"]."','".$_POST["switch_uplink"]."','".$_POST["switch_core"]."','".$_POST["switch_connected"]."')";
          mysqli_query($con, $sql);
        }
      }
    }
    ?>
    <button type="submit" class="btn btn-primary">Next</button>
  </form>
  "<?php
}

else if(@$_GET["switch"] == null or @$_GET["switch"] == "") {
  #LIST ALL SWITCHES
  ?>
  <div class="table-responsive">
  <table class="table">
  <?php
  $sql =
  "SELECT a.id, a.name, a.model, a.ip, a.latency_ms FROM switches a  WHERE a.ip IS NOT NULL";
  echo '<tr class="info">';
  echo "<td><b>Name</b></td>";
  echo "<td><b>Model</b></td>";
  echo "<td><b>IP</b></td>";
  #echo "<td><b>Connected to</b></td>";
  echo "<td></td>";
  echo "</tr>";
  $result = mysqli_query($con,$sql);
    while($row = mysqli_fetch_array($result))
    {
      if($row["latency_ms"] != null) {
      echo '<tr class="success">';
    }
    else {
      echo '<tr class="danger">';
    }
      echo "<td>".$row["name"]."</td>";
      echo "<td>".$row["model"]."</td>";
      echo "<td>".$row["ip"]."</td>";
      #echo "<td>".$row["corename"].":".$row["distro_port"]."</td>";
      echo "<td><a href='/index.php?page=port_traffic&switch=".$row["id"]."'>Port stats</a></td>";
      echo "</tr>";
    }
    ?>
  </table>
 </div>
    <?php
}
else {
  echo "EHM 404";
}
