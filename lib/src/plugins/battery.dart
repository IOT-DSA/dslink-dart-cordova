part of dslink.mobile.plugins;

class BatteryPlugin extends Plugin {
  @override
  init() {
    ValueNode batteryNode = createValueNode("/Battery/Level", "number");

    js.context.callMethod("addEventListener", [
      "batterystatus",
      (e) => batteryNode.updateValue(new JsObject.fromBrowserObject(e)["level"])
    ]);
  }
}
