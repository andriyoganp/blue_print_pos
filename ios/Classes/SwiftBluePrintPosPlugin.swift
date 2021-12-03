import Flutter
import UIKit
import WebKit

public class SwiftBluePrintPosPlugin: NSObject, FlutterPlugin {
  var webView : WKWebView!
  var urlObservation: NSKeyValueObservation?

  public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "blue_print_pos", binaryMessenger: registrar.messenger())
        let instance = SwiftBluePrintPosPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        // binding native view to flutter widget
        let viewID = "webview-view-type"
        let factory = FLNativeViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: viewID)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = call.method
        let arguments = call.arguments as? [String: Any]
        let content = arguments!["content"] as? String
        var duration = arguments!["duration"] as? Double
        if (duration==nil) { duration = 2000.0 }
        switch method {
        case "contentToImage":
            self.webView = WKWebView()
            self.webView.isHidden = true
            self.webView.tag = 100
            self.webView.loadHTMLString(content!, baseURL: Bundle.main.resourceURL)// load html into hidden webview
            var bytes = FlutterStandardTypedData.init(bytes: Data() )
            urlObservation = webView.observe(\.isLoading, changeHandler: { (webView, change) in
                DispatchQueue.main.asyncAfter(deadline: .now() + (duration!/10000) ) {
                        print("height = \(self.webView.scrollView.contentSize.height)")
                        print("width = \(self.webView.scrollView.contentSize.width)")
                    if #available(iOS 11.0, *) {
                        let configuration = WKSnapshotConfiguration()
                        configuration.rect = CGRect(origin: .zero, size: (self.webView.scrollView.contentSize))
                        self.webView.snapshotView(afterScreenUpdates: true)
                        self.webView.takeSnapshot(with: configuration) { (image, error) in
                            guard let data = image!.jpegData(compressionQuality: 1) else {
                                result( bytes )
                                self.dispose()
                                return
                            }
                            bytes = FlutterStandardTypedData.init(bytes: data)
                            result(bytes)
                            self.dispose()
                            print("Got snapshot")
                        }
                    } else if #available(iOS 9.0, *) {

                        let image =  self.webView.snapshot()
                        guard let data = image!.jpegData(compressionQuality: 1) else {
                            result( bytes )
                            self.dispose()
                            return
                        }
                        bytes = FlutterStandardTypedData.init(bytes: data)
                        result(bytes)
                        self.dispose()
                        print("Got snapshot")


                    } else {

                        result( bytes )
                        self.dispose()
                    }

                }
            })

            break
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
  }

  func dispose() {
      //dispose
      if let viewWithTag = self.webView.viewWithTag(100) {
          viewWithTag.removeFromSuperview() // remove hidden webview when pdf is generated
          // clear WKWebView cache
          if #available(iOS 9.0, *) {
              WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                  records.forEach { record in
                      WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                  }
              }
          }
      }
      self.webView = nil
  }
}

// WKWebView extension for export web html content into pdf
extension WKWebView {

    func snapshot() -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0);
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: true);
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return snapshotImage;
    }
}
