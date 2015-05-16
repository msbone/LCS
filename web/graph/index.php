<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/1.0.2/Chart.js"></script>
<canvas id="myChart" width="800" height="400"></canvas>
<script>
Chart.defaults.global.responsive = true;
Chart.defaults.global.animation = false;


var ctx = document.getElementById("myChart").getContext("2d");
var chartData = {
  labels: [],
  datasets: [
    {
      label: "Ping in MS",
      fillColor: "rgba(0, 38, 69, 0.4)",
      strokeColor: "rgba(0, 0, 69, 1)",
      data: []
    }
  ]
};
var myLineChart;

$.getJSON( "ping_json.php", function( data ) {
$.each( data, function( key, val ) {
console.log(val.latency);
chartData.datasets[0].data.push(val.latency);
chartData.labels.push(key);
});
}).done(function() {
myLineChart = new Chart(ctx).Line(chartData);
  });

function LoadStats() {
$.getJSON( "ping_json.php", function( data ) {
$.each( data, function( key, val ) {
console.log(val.latency);
myLineChart.removeData();
myLineChart.addData([val.latency], key);
});
}).done(function() {
  });
}
setInterval( LoadStats, 5000 );

</script>
