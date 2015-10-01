<?php
include("database.php");
?>

<div class="row">
  <div class="col-md-2">
<select id="from" multiple="multiple">
  <optgroup label="Switches">
    <?php
     $sql = "SELECT * FROM switches";
    $result = mysqli_query($con,$sql);
      while($row = mysqli_fetch_array($result))
      {
        echo "<option value='sw".$row["id"]."' selected='selected'>".$row["name"]."</option>";
}
        ?>
    </optgroup>
    <optgroup label="Other">
    <option value="snmpfetch" selected="selected">Snmpfetch</option>
    <option value="dhcp" selected="selected">Dhcp</option>
    <option value="other" selected="selected">Other</option>
    </optgroup>
</select>
  </div>
  <div class="col-md-2">
<select id="type" multiple="multiple">
    <option value="1" selected="selected">Cronjobs</option>
    <optgroup label="SNMP">
    <option value="11" selected="selected">Start/Stop</option>
    <option value="12" selected="selected">New port</option>
    <option value="13" selected="selected">Port changed</option>
    <option value="19" selected="selected">Other</option>
    </optgroup>
    <optgroup label="DHCP">
    <option value="21" selected="selected">Lease</option>
    <option value="29" selected="selected">Other</option>
    </optgroup>
    <optgroup label="Other">
    <option value="1000" selected="selected">Other</option>
    </optgroup>
</select>
  </div>
  <div class="col-md-2">
<select id="priority" multiple="multiple">
    <option value="1" selected="selected">Super high</option>
    <option value="2" selected="selected">High</option>
    <option value="3" selected="selected">Medium</option>
    <option value="4" selected="selected">Low</option>
    <option value="5" selected="selected">Info</option>
    <option value="9" selected="selected">Debug</option>
</select>
  </div>
  <div class="visible-lg col-md-1 col-md-offset-5"><span style="font-size:2em;" id="reload" class="glyphicon glyphicon-refresh" aria-hidden="true"></span></div>
</div>
<br/>

<div id="log_wrapper">
</div>

<nav>
  <ul class="pagination">
    <li>
      <span id="prePage" aria-hidden="true">&laquo;</span>
        <span id="home" class="glyphicon glyphicon-home" aria-hidden="true"></span>
        <span id="nexPage" aria-hidden="true">&raquo;</span>
    </li>
  </ul>
</nav>
<script type="text/javascript">

var page = 1;
    $(document).ready(function() {
      var fromValues = $('#from').val();
      var typeValues = $('#type').val();
      var priorityValues = $('#priority').val();
      $.get( "/pages/syslog_data.php",{from: fromValues,type: typeValues,priority: priorityValues, page: page}, function( data ) {
        $( "#log_wrapper" ).html( data );
      });

$('#reload').click(function(){
  $.get( "/pages/syslog_data.php",{from: fromValues,type: typeValues,priority: priorityValues, page: page}, function( data ) {
    $( "#log_wrapper" ).html( data );
  });
});

$('#prePage').click(function(){
  if(page > 1) {
    page--;
  }
  $.get( "/pages/syslog_data.php",{from: fromValues,type: typeValues,priority: priorityValues, page: page}, function( data ) {
    $( "#log_wrapper" ).html( data );
  });
});
$('#home').click(function(){
  page = 1;
  $.get( "/pages/syslog_data.php",{from: fromValues,type: typeValues,priority: priorityValues, page: page}, function( data ) {
    $( "#log_wrapper" ).html( data );
  });
});
$('#nexPage').click(function(){
  page++;
  $.get( "/pages/syslog_data.php",{from: fromValues,type: typeValues,priority: priorityValues, page: page}, function( data ) {
    $( "#log_wrapper" ).html( data );
  });
});

$('#from').multiselect({
maxHeight: 500,
includeSelectAllOption: true,
enableFiltering: true,
enableCaseInsensitiveFiltering: true,
enableClickableOptGroups: true,
onChange: function(element, checked) {
  page = 1;
  fromValues = $('#from').val();
  typeValues = $('#type').val();
  priorityValues = $('#priority').val();
  $.get( "/pages/syslog_data.php",{from: fromValues,type: typeValues,priority: priorityValues, page: page}, function( data ) {
$( "#log_wrapper" ).html( data );
  });
}
});
$('#type').multiselect({
maxHeight: 500,
includeSelectAllOption: true,
enableFiltering: true,
enableCaseInsensitiveFiltering: true,
enableClickableOptGroups: true,
onChange: function(element, checked) {
  page = 1;
  fromValues = $('#from').val();
  typeValues = $('#type').val();
  priorityValues = $('#priority').val();
  $.get( "/pages/syslog_data.php",{from: fromValues,type: typeValues,priority: priorityValues, page: page}, function( data ) {
$( "#log_wrapper" ).html( data );
  });
}
});
$('#priority').multiselect({
maxHeight: 500,
includeSelectAllOption: true,
enableFiltering: true,
enableCaseInsensitiveFiltering: true,
enableClickableOptGroups: true,
onChange: function(element, checked) {
  page = 1;
  fromValues = $('#from').val();
  typeValues = $('#type').val();
  priorityValues = $('#priority').val();
  $.get( "/pages/syslog_data.php",{from: fromValues,type: typeValues,priority: priorityValues, page: page}, function( data ) {
$( "#log_wrapper" ).html( data );
  });
}
});
    });
</script>
