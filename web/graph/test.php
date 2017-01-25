<script
  src="https://code.jquery.com/jquery-3.1.1.min.js"
  integrity="sha256-hVVnYaiADRTO2PzUGmuLJr8BLUSjGIZsDYGmIJLv2b8="
  crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/2.4.0/Chart.bundle.min.js"></script>

<canvas id="myChart" width="800" height="300"></canvas>


<script>
Chart.defaults.global.responsive = false;
Chart.defaults.global.animation = false;

var ctx = document.getElementById("myChart").getContext("2d");

var chartData = {
  labels: [],
  datasets: [
    {
      label: "In",
      data: [],
      backgroundColor: "rgba(0,95,129,0.4)",
      borderColor: "rgba(75,192,192,1)",
    },
    {
      label: "Out",
      data: [],
      backgroundColor: "rgba(75,192,192,0.4)",
      borderColor: "rgba(75,192,192,1)",
    }
  ]
};

var myLineChart;

$.getJSON( "influx_port_api.php?port=6", function( data ) {
$.each( data, function( key, val ) {
  chartData.labels.push(val.time);
  chartData.datasets[0].data.push(val.in);
  chartData.datasets[1].data.push(-Math.abs(val.out));
});
}).done(function() {
myLineChart = new Chart(ctx, {
    type: 'line',
    data: chartData,
    options: {
        responsive: false
    },
    xaxis: {
        mode: "time",
        timeformat: "%H:%M",
        tickSize: [1, "hour"],
        twelveHourClock: false,
        timezone: "browser" // switch to using local time on plot
    },
});
  });

</script>
