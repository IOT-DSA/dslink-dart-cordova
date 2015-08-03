part of dslink.mobile.plugins;

class CompassPlugin extends Plugin {
  @override
  init() {
    StreamSubscription sub;
    ValueNode headingNode;

    var compass = loadJsObject("navigator.compass");
    int mid;
    StreamController m;
    m = new StreamController.broadcast(onListen: () {
      mid = compass.callMethod("watchHeading", [
        (o) => m.add(o["magneticHeading"]),
        (e) => null
      ]);
    }, onCancel: () {
      compass.callMethod("clearWatch", [mid]);
    });

    headingNode = createValueNode("/Compass/Heading", "number", onListenChange: (status) {
      if (status) {
        sub = m.stream.listen((o) {
          headingNode.updateValue(o);
        });
      } else {
        if (sub != null) {
          sub.cancel();
        }
      }
    });
  }
}
