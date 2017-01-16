$(function() {
  $(document).keydown(function(e) {
    // Simulate a click on the "done" button when Enter is pressed anywhere
    if (e.keyCode == 13) {
      $("#done").click();
    }
  });
});
