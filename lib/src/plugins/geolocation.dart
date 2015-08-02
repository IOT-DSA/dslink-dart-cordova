part of dslink.mobile.plugins;

class GeolocationPlugin extends Plugin {
  @override
  init() {
    createActionNode("/Geolocation/getPosition", (Map<String, dynamic> params) async {
      var position = await window.navigator.geolocation.getCurrentPosition();
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
