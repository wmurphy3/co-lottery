$(document).on('turbolinks:load', function () {
  if ($('#login-search').length != 0) {
    $('#login-search').parsley().on('form:validate', function (formInstance) {
    }).on('form:submit', function () {
      return ($('.parsley-error').length === 0)
    });
  }

  if ($('#signup').length != 0) {
    $('#signup').parsley().on('form:validate', function (formInstance) {
    }).on('form:submit', function () {
      return ($('.parsley-error').length === 0)
    });
  }
})