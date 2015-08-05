part of dslink.mobile.plugins;

class GeofencePlugin extends Plugin {
  @override
  init() async {
    var geofence = loadJsObject("geofence");

    await promiseToFuture(geofence.callMethod("initialize"));
    var fences = JSON.decode(await promiseToFuture(geofence.callMethod("getWatched")));

    removeGeofence(name) async {
      await promiseToFuture(geofence.callMethod("remove", [name]));
      link.removeNode("/Geofence/${name}");
    }

    loadGeofence(fence) {
      var name = fence["id"];
      var latitude = fence["latitude"];
      var longitude = fence["longitude"];
      var radius = fence["radius"];

      createValueNode("/Geofence/${name}/Name", "string", value: name);
      createValueNode("/Geofence/${name}/Latitude", "number", value: latitude);
      createValueNode("/Geofence/${name}/Longitude", "number", value: longitude);
      createValueNode("/Geofence/${name}/Radius", "number", value: radius);

      createActionNode("/Geofence/${name}/Remove", (params) {
        removeGeofence(name);
      });
    }

    for (var fence in fences) {
      await loadGeofence(fence);
    }

    addGeofence(String name, num latitude, num longitude, num radius) async {
      var m = {
        "id": name,
        "latitude": latitude,
        "longitude": longitude,
        "radius": radius
      };
      await promiseToFuture(geofence.callMethod("addorUpdate", [jsify(m)]));
      await loadGeofence(m);
    }

    createActionNode("/Geofence/Add_Geofence", (params) async {
      var name = params["name"];
      var latitude = params["latitude"];
      var longitude = params["longitude"];
      var radius = params["radius"];

      await addGeofence(name, latitude, longitude, radius);
    }, name: "Add Geofence");
  }
}
