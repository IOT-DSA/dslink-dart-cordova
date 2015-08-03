part of dslink.mobile.plugins;

class GeolocationPlugin extends Plugin {
  @override
  init() {
    StreamSubscription sub;
    ValueNode latitudeNode;
    ValueNode longitudeNode;
    ValueNode altitudeNode;

    var statuses = [
      false,
      false,
      false
    ];

    check() async {
      if (statuses.every((x) => !x) && sub != null) {
        sub.cancel();
      }

      if (statuses.any((x) => x)) {
        sub = window.navigator.geolocation.watchPosition(enableHighAccuracy: true).listen((Geoposition pos) {
          var c = pos.coords;
          latitudeNode.updateValue(c.latitude);
          longitudeNode.updateValue(c.longitude);
          altitudeNode.updateValue(c.altitude);
        });
      }
    }

    latitudeNode = createValueNode("/Geolocation/Latitude", "number", onListenChange: (status) {
      statuses[0] = status;
      check();
    });

    longitudeNode = createValueNode("/Geolocation/Longitude", "number", onListenChange: (status) {
      statuses[1] = status;
      check();
    });

    altitudeNode = createValueNode("/Geolocation/Altitude", "number", onListenChange: (status) {
      statuses[2] = status;
      check();
    });

    createActionNode("/Geolocation/getPosition", (Map<String, dynamic> params) async {
      var position = await window.navigator.geolocation.getCurrentPosition(enableHighAccuracy: true);
      var c = position.coords;

      return {
        "latitude": c.latitude,
        "longitude": c.longitude,
        "alitude": c.altitude,
        "accuracy": c.accuracy,
        "heading": c.heading,
        "speed": c.speed,
        "timestamp": position.timestamp
      };
    }, results: {
      "latitude": "number",
      "longitude": "number",
      "altitude": "number",
      "accuracy": "number",
      "heading": "number",
      "speed": "number",
      "timestamp": "number"
    }, name: "Get Position");
  }
}
