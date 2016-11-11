$(document).ready(function() {
  // map settings
  var stamenType = "terrain";
  var startLat = 43;
  var startLong = -105;
  var startZoom = 5;
  var markerColor = "#000000";

  // This will need to be constructed from rails based on locations
  var locations = [
    {
      "name" : "Place Name",
      "latlong" : [42.10, -102.87],
      "entries" : [
        {
          "title" : "January 10, 1804 - Clark",
          "id" : "lc.1804.01"
        }
      ]
    }
  ];

  var map = L.map('map_container')
             .setView(new L.LatLng(startLat, startLong), startZoom);

  // make base layer
  var stamenLayer = new L.StamenTileLayer(stamenType);
  map.addLayer(stamenLayer);

  var makeLinks = function(loc_name, entries) {
    if (entries) {
      var res = "<h4 class='map_entry'>"+loc_name+"</h4>";
      for (var i = 0; i < entries.length; i++) {
        res += singleLink(entries[i])
      }
      return res;
    } else {
      return "No entries found for this location";
    }
  };

  var singleLink = function(entry) {
    return "<li class='map_entry_link'>"
           +"<a href='../item/"
           +entry["id"]+"/'>"+entry["title"]+"</a></li>";
  };

  var circleMarkers = {
    radius: 4,
    fillColor: markerColor,
    color: markerColor,
    weight: 1,
    opacity: 1,
    fillOpacity: .8
  };

  locations.forEach(function(loc) {
    var marker = L.circleMarker(loc["latlong"], circleMarkers);
    marker.addTo(map);
    marker.bindPopup(makeLinks(loc["name"], loc["entries"]));
    
    // add a mouseover that waits for you to click away before closing
    marker.on('mouseover', function(e) {
      this.openPopup();
    });
    marker.on('click', function(e) {
      this.closePopup();
    });
  });
});
