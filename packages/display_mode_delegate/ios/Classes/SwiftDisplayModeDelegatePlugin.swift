import Flutter
import UIKit

public class SwiftDisplayModeDelegatePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "rhythm_native/display_mode_delegate", binaryMessenger: registrar.messenger())
    let instance = SwiftDisplayModeDelegatePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
