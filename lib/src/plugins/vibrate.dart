part of dslink.mobile.plugins;

class VibratePlugin extends Plugin {
  @override
  init() {
    var nav = loadJsObject("navigator");

    createActionNode("/Vibration/Vibrate", (Map<String, dynamic> params) async {
      nav.callMethod("vibrate", [
        params["time"] == null ? 1000 : params["time"].toInt()
      ]);
    }, params: {
      "time": "number"
    });
  }
}
