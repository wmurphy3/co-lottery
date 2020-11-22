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
//= toastr
//= require_tree .

toastr.options = {
  closeButton: true,
  debug: false,
  newestOnTop: false,
  progressBar: false,
  positionClass: "toast-bottom-center",
  preventDuplicates: false,
  onclick: null,
  showDuration: "300",
  hideDuration: "1000",
  showEasing: "swing",
  hideEasing: "linear",
  showMethod: "fadeIn",
  hideMethod: "fadeOut",
};

$(document).on('turbolinks:load', function () {
  if ($('.game-piece').length > 0) {
    var finished_game = $('.finished_game').val() == "false";

    // Only get next piece if the game wasn't finished earlier
    if (finished_game) {
      getNextPrize();
    }
  }

  // Confirmed over 18
  $('#confirm').click(function () {
    $('.enter-raffle').removeAttr("disabled");
  });

  // Player chose to open gift
  $('.game-piece.player').click(function () {
    var action = $(this).find(".button-player p").text();

    if (action == "KEEP") {
      $.ajax({
        type: 'get',
        url: ('/games/get_next'),
        async: false,
        dataType: 'script',
        success: function(data) {}
      });
    } else {
      var myModal = new bootstrap.Modal(document.getElementById('myPrizeModal'), {})
      myModal.show();
    }
  });

  $('.game-piece.bot').click(function () {
    var finished_game   = $('.finished_game').val() == "true";
    var action          = $(this).find('.button-player p').text();
    
    if (finished_game && action == "STEAL") {
      var index = $(this).index();

      $.ajax({
        type: 'get',
        url: ('/games/'+index+'/steal'),
        async: false,
        dataType: 'script',
        success: function(data) {}
      });
    }
  });

  $('.signed_up').click(function () {
    $('.sign-up').addClass('d-none');
    $('.sign-in').removeClass('d-none');
  });

  $('.sign_up').click(function () {
    $('.sign-up').removeClass('d-none');
    $('.sign-in').addClass('d-none');
  });
});

// Get the next prize depending on cache
function getNextPrize() {
  setTimeout(function () {
    $.ajax({
      type: 'get',
      url: ('/games/get_next'),
      async: false,
      dataType: 'script',
      success: function (data) {}
    });
  }, 3000);
}
