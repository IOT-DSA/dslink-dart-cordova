library dslink.mobile.plugins;

import "dart:async";

import "package:dslink/browser.dart";
import "package:dslink/nodes.dart";

import "dart:js" as js;
import "dart:js" show JsObject, JsArray, JsFunction;

part "src/plugins/barcode.dart";

final List<Plugin> PLUGINS = [
  new BarcodeScannerPlugin()
];

LinkProvider link;

loadPlugins() async {
  for (var plugin in PLUGINS) {
    await plugin.init();
  }
}

abstract class Plugin {
  init();
}

JsObject loadJsObject(String code) => js.context.callMethod("eval", [code]);
JsObject toJsObject(value) => new JsObject.jsify(value);

Map createValueNode(String type, {String name, dynamic value}) {
  var map = {
    r"$type": type
  };

  if (name != null) {
    map[r"$name"] = name;
  }

  if (value != null) {
    map["?value"] = value;
  }

  return map;
}

SimpleActionNode createActionNode(String path, handler(Map<String, dynamic> params), {bool table: false, params, results, String permission: "read"}) {
  var map = {
    r"$invokable": permission,
    r"$result": table ? "table" : "values",
    r"$params": params != null ? params : params,
    r"$columns": results != null ? results : results
  };

  var node = new SimpleActionNode(path, handler, link.provider);
  node.load(map);
  SimpleNodeProvider p = link.provider;

  p.getOrCreateNode(new Path(path).parent.path);

  p.setNode(path, node);
  return node;
}
