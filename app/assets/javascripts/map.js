$(document).ready(function() {
  // map settings
  var markerColor = "#36659c";
  var startLat = 43;
  var startLong = -105;
  var startZoom = 5;

  var circleMarkers = {
    color: markerColor,
    fillColor: markerColor,
    fillOpacity: .8,
    opacity: 1,
    radius: 3,
    weight: 1
  };

  // This is an example of the object constructed by rails
  // var locations = [
  //   {
  //     "name" : "Place Name",
  //     "latlong" : [42.10, -102.87],
  //     "entries" : [
  //       {
  //         "title" : "January 10, 1804 - Clark",
  //         "id" : "lc.1804.01"
  //       }
  //     ]
  //   }
  // ];

  var map = L.map("map_container")
             .setView(new L.LatLng(startLat, startLong), startZoom);

  // make base layer
  var baseLayer = L.tileLayer('https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attributionControl: false
  });
  map.addLayer(baseLayer);
  L.control.attribution({
    position: 'bottomleft',
    prefix: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, Tiles style by <a href="https://www.hotosm.org/" target="_blank">Humanitarian OpenStreetMap Team</a> hosted by <a href="https://openstreetmap.fr/" target="_blank">OpenStreetMap France</a>'
  }).addTo(map);
  var makeLinks = function(loc_name, entries) {
    if (entries) {
      var res = "<h4>" + loc_name + "</h4>";
      res += '<ul class="map_entries">';
      var entry_len = entries.length;
      for (var i = 0; i < entry_len; i++) {
        res += singleLink(entries[i])
      }
      res += "</ul>";
      return res;
    } else {
      return "No entries found for this location";
    }
  };

  var singleLink = function(entry) {
    return "<li>"
           + '<a href="'
           + location.protocol
           + '//'
           + location.host + location.pathname
           + '/../item/'
           + entry["id"]+'">'
           + entry["title"] + "</a></li>";
  };

  locations.forEach(function(loc) {
    var marker = L.circleMarker(loc["latlong"], circleMarkers);
    marker.addTo(map);
    marker.bindPopup(makeLinks(loc["name"], loc["entries"]));
    
    // add a mouseover that waits for you to click away before closing
    marker.on("mouseover", function(e) {
      this.openPopup();
    });
    marker.on("click", function(e) {
      this.closePopup();
    });
  });
});
