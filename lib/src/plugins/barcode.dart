part of dslink.mobile.plugins;

class BarcodeScannerPlugin extends Plugin {
  @override
  init() {
    var scanner = loadJsObject("cordova.plugins.barcodeScanner");

    createActionNode("/Barcodes/Scan", (Map<String, dynamic> params) async {
      var completer = new Completer.sync();
      scanner.callMethod("scan", [
          (JsObject result) {
          String text = result["text"];
          String format = result["format"];
          bool cancelled = result["cancelled"];

          completer.complete({
            "text": text,
            "format": format,
            "cancelled": cancelled
          });
        },
          (JsObject error) {
          completer.completeError(error);
        }
      ]);
      return await completer.future;
    }, results: [
      {
        "name": "text",
        "type": "string"
      },
      {
        "name": "format",
        "type": "string"
      },
      {
        "name": "cancelled",
        "type": "bool"
      }
    ]);
  }
}
