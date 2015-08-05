library dslink.mobile.plugins;

import "dart:async";
import "dart:html";

import "package:dslink/browser.dart";
import "package:dslink/nodes.dart";

import "dart:js" as js;
import "dart:js" show JsObject, JsArray, JsFunction;
import "dart:convert";

part "src/plugins/barcode.dart";
part "src/plugins/geolocation.dart";
part "src/plugins/vibrate.dart";
part "src/plugins/compass.dart";
part "src/plugins/battery.dart";
part "src/plugins/geofence.dart";

final List<Plugin> PLUGINS = [
  new BarcodeScannerPlugin(),
  new GeolocationPlugin(),
  new VibratePlugin(),
  new CompassPlugin(),
  new BatteryPlugin(),
  new GeofencePlugin()
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

Map createInitialValueNode(String type, {String name, dynamic value}) {
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

SimpleActionNode createActionNode(String path, handler(Map<String, dynamic> params), {String name, bool table: false, params, results, String permission: "read"}) {
  if (results is Map) {
    var m = new Map.from(results);
    results = [];
    for (var k in m.keys) {
      results.add({
        "name": k,
        "type": m[k]
      });
    }
  }

  if (params is Map) {
    var m = new Map.from(params);
    params = [];
    for (var k in m.keys) {
      params.add({
        "name": k,
        "type": m[k]
      });
    }
  }

  var map = {
    r"$invokable": permission,
    r"$result": table ? "table" : "values",
    r"$params": params != null ? params : params,
    r"$columns": results != null ? results : results
  };

  if (name != null) {
    map[r"$name"] = name;
  }

  var node = new SimpleActionNode(path, handler, link.provider);
  node.load(map);
  SimpleNodeProvider p = link.provider;

  p.getOrCreateNode(new Path(path).parent.path);

  p.setNode(path, node);
  return node;
}

SimpleNode createValueNode(String path, String type, {String name, OnListenerStatusChange onListenChange, dynamic value}) {
  var map = {
    r"$name": name,
    r"$type": type
  };

  if (value != null) {
    map["?value"] = value;
  }

  if (link.getNode(path) != null) {
    link.removeNode(path);
  }

  var node = new ValueNode(path);
  node.load(map);
  node.onListenerStatusChange = onListenChange;
  SimpleNodeProvider p = link.provider;

  p.getOrCreateNode(new Path(path).parent.path);

  p.setNode(path, node);
  return node;
}

typedef OnListenerStatusChange(bool status);

class ValueNode extends SimpleNode {
  ValueNode(String path) : super(path, link.provider);

  OnListenerStatusChange onListenerStatusChange;

  @override
  RespSubscribeListener subscribe(callback(ValueUpdate), [int cacheLevel = 1]) {
    if (!hasSubscriber && onListenerStatusChange != null) {
      onListenerStatusChange(true);
    }
    return super.subscribe(callback, cacheLevel);
  }

  @override
  void unsubscribe(callback(ValueUpdate update)) {
    super.unsubscribe(callback);
    if (!hasSubscriber && onListenerStatusChange != null) {
      onListenerStatusChange(false);
    }
  }
}

js.JsObject jsify(Map map) => new js.JsObject.jsify(map);

Future promiseToFuture(promise) {
  if (promise is js.JsObject) {
    promise = new Promise(promise);
  }

  if (promise is! Promise) {
    throw new Exception("Unknown Promise Type");
  }

  var completer = new Completer();
  promise.then(([e]) {
    completer.complete(e);
  });

  promise.catchError(([e]) {
    completer.completeError(e);
  });

  return completer.future;
}

class Promise {
  static Promise all(List input) {
    return js.context["Promise"].callMethod("all", [input]);
  }

  final js.JsObject obj;

  Promise(this.obj);

  Promise then(Function func) {
    return new Promise(obj.callMethod("then", [func]));
  }

  Promise catchError(Function func) {
    return new Promise(obj.callMethod("catch", [func]));
  }
}

abstract class ProxyHolder extends Object {
  final js.JsObject obj;

  ProxyHolder(this.obj);

  dynamic invoke(String method, [dynamic arg1, dynamic arg2, dynamic arg3]) {
    if (arg1 is Map) arg1 = jsify(arg1);
    if (arg2 is Map) arg2 = jsify(arg2);
    if (arg3 is Map) arg3 = jsify(arg3);

    if (arg3 != null) {
      return obj.callMethod(method, [arg1, arg2, arg3]);
    } else if (arg2 != null) {
      return obj.callMethod(method, [arg1, arg2]);
    } else if (arg1 != null) {
      return obj.callMethod(method, [arg1]);
    } else {
      return obj.callMethod(method);
    }
  }
}
