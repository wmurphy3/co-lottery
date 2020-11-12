// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require bootstrap
//= require jquery3
//= require popper
//= require parsley
//= require_tree .

$(document).on('turbolinks:load', function () {
  if ($('.game-piece').length > 0) {
    var finished_game = $('.finished_game').val() == "false";

    // Only get next piece if the game wasn't finished earlier
    if (finished_game) {
      getNextPrize();
    }
  }

  $('#confirm').click(function () {
    $('.enter-raffle').removeAttr("disabled");
  });
});

// Get the next prize depending on cache
function getNextPrize() {
  // TODO show loading gif?
  setTimeout(function () {
    $.ajax({
      type: 'get',
      url: ('/games/get_next'),
      async: false,
      dataType: 'script',
      success: function(data) {}
    });
  }, 3000);
}
