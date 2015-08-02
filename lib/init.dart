library dslink.mobile.init;

import "package:dslink/browser.dart";
import "package:rikulo_gap/device.dart";
import "plugins.dart";

Device device;

init() async {
  device = await Device.init();

  link = new LinkProvider("http://dglux.directcode.org/conn", "Cordova-", defaultNodes: {
    "Cordova": {
      "Platform": createInitialValueNode("string", value: device.platform),
      "Version": createInitialValueNode("string", value: device.version)
    }
  });
  await link.connect();
  await loadPlugins();
  print("Connected.");
}
