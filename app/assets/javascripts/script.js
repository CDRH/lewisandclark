/* Project Specific JavaScript */

$( document ).ready(function() {
  $('.not_journal').click(function(){
    $('#journal_search_options.in')
    .collapse('hide');
  });

});

// must require bootstrap before this will work
$(function () {
  $('[data-toggle="tooltip"]').tooltip()
});

$(document).delegate('*[data-toggle="lightbox"]', 'click', function(event) {
    event.preventDefault();
    $(this).ekkoLightbox();
});
