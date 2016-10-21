var popup = function(e) {
  var days = e.events;
  if(days.length > 0) {
    var content = '';
    for(var i in days) {
      var day = days[i];
      content += '<div class="event-tooltip-content">'
      + '<div class="event-name" style="color:' + day.color + '">' + day.name + '</div>'
      + '<div class="event-location">' + day.location + '</div>'
      + '</div>';
    }
    $(e.element).popover({ 
      trigger: 'manual',
      container: 'body',
      html:true,
      content: content
    });
    $(e.element).popover('show');
  }
}

// note: popover requires bootstrap to be loaded
$(document).ready(function() {
  $('#calendar').calendar({
    maxDate: new Date("1807"),
    minDate: new Date("1803"),
    startYear: "1803",
    mouseOnDay: function(e) { popup(e); },
    mouseOutDay: function(e) {
      if(e.events.length > 0) {
        $(e.element).popover('hide');
      }
    },
    // dayContextMenu: function(e) {
    //   $(e.element).popover('hide');
    // },
    dataSource: dates
  });
});
