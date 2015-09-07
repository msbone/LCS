$(document).ready(function() {

var index = 0;

setInterval(function () {
  $.getJSON( "pages-json.php", function( data ) {
    var pages = new Array();
    $.each( data, function( key, val ) {
pages.push(val);
    });
    $.ajax({
      type: "POST",
      url: "page.php",
      cache: false,
      data: { id: pages[0][index] }
    })
      .done(function( html ) {
        $( "#wrapper" ).html( html );
        if(Object.keys(pages[0]).length <= index +1) {
          index = 0;
        }else {
          index++;
        }
      });
});
}, 10000);
  });

setInterval(function() {
  var hours;
  var minutes;
  var seconds;

    var date = new Date();
    if(date.getHours() < 10) {
      hours = '0'+date.getHours();
    } else {
      hours = date.getHours();
    }
    if(date.getMinutes() < 10) {
      minutes = '0'+date.getMinutes();
    } else {
      minutes = date.getMinutes();
    }
    if(date.getSeconds() < 10) {
      seconds = '0'+date.getSeconds();
    } else {
      seconds = date.getSeconds();
    }


        $('#clock').html(
            hours + ":" + minutes + ":" + seconds
            );
    }, 500);
