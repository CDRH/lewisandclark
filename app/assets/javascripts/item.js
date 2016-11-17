$(function () {
  // Name tooltips - Requires bootstrap
  $('[data-toggle="tooltip"]').tooltip()

  // Image lightboxes
  $('[data-toggle="lightbox"]').click(function(e) {
      e.preventDefault();
      $(this).ekkoLightbox();
  });
});

