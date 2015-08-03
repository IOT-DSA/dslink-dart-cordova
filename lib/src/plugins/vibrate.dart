part of dslink.mobile.plugins;

class VibratePlugin extends Plugin {
  @override
  init() {
    var nav = loadJsObject("navigator");

    createActionNode("/Vibrate", (Map<String, dynamic> params) async {
      nav.callMethod("vibrate");
    });
  }
}
