$('document').ready(function() {
  $('.dropdown-toggle').dropdown();
  $("#collapseOne").collapse("hide");
  $("#collapseOne").collapse("show");
  $('#soundcloud-button').click(function() {
    $(this).attr("disabled", 'disabled');
    $('#soundcloud').append('<iframe width="100%" height="166" scrolling="no" frameborder="no" src="http://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F69525722&show_artwork=true"></iframe>\
                            <iframe width="100%" height="166" scrolling="no" frameborder="no" src="http://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F54906444&show_artwork=true"></iframe>\
                            <iframe width="100%" height="166" scrolling="no" frameborder="no" src="http://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F54904557&show_artwork=true"></iframe>\
                            <iframe width="100%" height="166" scrolling="no" frameborder="no" src="http://w.soundcloud.com/player/?url=http%3A%2F%2Fapi.soundcloud.com%2Ftracks%2F54898737&show_artwork=true"></iframe>');
});
$('#youtube-button').click(function() {
  $(this).attr("disabled", 'disabled');
  $('#youtube').append('<iframe width="420" height="315" src="http://www.youtube.com/embed/bXgQsY03SFg" frameborder="0" allowfullscreen></iframe>\
                       <iframe width="420" height="315" src="http://www.youtube.com/embed/J_8X04iqK1A" frameborder="0" allowfullscreen></iframe>\
                       <iframe width="420" height="315" src="http://www.youtube.com/embed/4oRGu6TJND0" frameborder="0" allowfullscreen></iframe>');
});


$('.scrollPage').click(function() {
 var elementClicked = $(this).attr("href");
 var destination = $(elementClicked).offset().top;
 $("html:not(:animated),body:not(:animated)").animate({ scrollTop: destination-40}, 300 );
 return false;
});

$('.carousel').carousel({
  interval: false
});

});
