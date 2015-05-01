<ul class="nav nav-sidebar">
  <li <?php if(@$_GET["switch"] == "new") {echo 'class="active"';}?>><a href="/index.php?page=switches&switch=new">Create a new switch</a></li>
</ul>
<ul class="nav nav-sidebar">
  <li <?php if($_GET["page"] == "switchmap") {echo 'class="active"';}?>><a href="/index.php?page=switchmap">Ping map</a></li>
  <li><a href="#">Traffic map</a></li>
</ul>

<?php if($_GET["page"]  == "switchmap"){
?>
<div class="list-group">
  <p> Switches without placement, click to place</p>
  <?php
  include("database.php");
  $sql = "SELECT switches.name, switches.id FROM switches WHERE switches.id NOT IN (SELECT placements.switch FROM placements)";
  $result = mysqli_query($con,$sql);
  while($row = mysqli_fetch_array($result))
  {
    ?>
    <a href="/index.php?page=switchmap&place=<?php echo $row["id"]; ?>" class="list-group-item"><?php echo $row["name"]; ?></a>
    <?php
  }
  ?>
</div>
 <?php
} ?>
