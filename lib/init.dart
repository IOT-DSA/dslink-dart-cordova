library dslink.mobile.init;

import "package:dslink/browser.dart";
import "package:dslink/utils.dart";
import "package:rikulo_gap/device.dart";
import "plugins.dart";

import "dart:html";

Device device;

class NullNodeValidator implements NodeValidator {
  const NullNodeValidator();

  @override
  bool allowsElement(Element element) => true;

  @override
  bool allowsAttribute(Element element, String attributeName, String value) => true;
}

init() async {
  var logElement = querySelector("#log");

  device = await Device.init();

  logger.clearListeners();
  logger.onRecord.listen((record) {
    var current = logElement.innerHtml;
    var lines = current.split("<br/>").take(4).join("<br/>");
    logElement.setInnerHtml(
      lines +
      "<br/>" +
      "[${record.level.name.toUpperCase()}] ${record.message}",
      validator: const NullNodeValidator()
    );
  });

  logger.info("Ready");

  var pname = device.platform[0].toUpperCase() + device.platform.substring(1);
  if (pname == "Ios") {
    pname = "iOS";
  }
  link = new LinkProvider("http://rnd.iot-dsa.org/conn", "Cordova${pname}-", defaultNodes: {
    "Cordova": {
      "Platform": createInitialValueNode("string", value: device.platform),
      "Version": createInitialValueNode("string", value: device.version)
    }
  });
  await link.connect();
  await loadPlugins();
  print("Connected.");
}
