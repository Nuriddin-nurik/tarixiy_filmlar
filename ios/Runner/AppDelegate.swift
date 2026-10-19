import Flutter
import UIKit
import flutter_foreground_task

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var captureCover: UIView?
  private var secureEnabled = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback(registerPlugins)
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      let messenger = controller.binaryMessenger

      FlutterMethodChannel(name: "tarixiy/storage", binaryMessenger: messenger)
        .setMethodCallHandler { call, result in
          guard call.method == "freeBytes" else {
            result(FlutterMethodNotImplemented)
            return
          }
          let url = URL(fileURLWithPath: NSHomeDirectory())
          let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey])
          if let free = values?.volumeAvailableCapacityForImportantUsage {
            result(NSNumber(value: free))
          } else {
            result(nil)
          }
        }

      FlutterMethodChannel(name: "tarixiy/secure", binaryMessenger: messenger)
        .setMethodCallHandler { [weak self] call, result in
          switch call.method {
          case "enable":
            self?.secureEnabled = true
            self?.updateCaptureCover()
            result(nil)
          case "disable":
            self?.secureEnabled = false
            self?.updateCaptureCover()
            result(nil)
          default:
            result(FlutterMethodNotImplemented)
          }
        }
    }

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(updateCaptureCover),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  @objc private func updateCaptureCover() {
    DispatchQueue.main.async {
      guard let window = self.window else { return }
      if self.secureEnabled && UIScreen.main.isCaptured {
        if self.captureCover == nil {
          let cover = UIView(frame: window.bounds)
          cover.backgroundColor = .black
          cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]
          window.addSubview(cover)
          self.captureCover = cover
        }
      } else {
        self.captureCover?.removeFromSuperview()
        self.captureCover = nil
      }
    }
  }
}

func registerPlugins(registry: FlutterPluginRegistry) {
  GeneratedPluginRegistrant.register(with: registry)
}
