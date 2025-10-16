import Flutter
import UIKit
import Photos

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // 注册原生分享插件
    if let controller = window?.rootViewController as? FlutterViewController {
      let nativeShareChannel = FlutterMethodChannel(name: "native_share", binaryMessenger: controller.binaryMessenger)
      nativeShareChannel.setMethodCallHandler { (call, result) in
        self.handleNativeShare(call: call, result: result)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleNativeShare(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "shareImage":
      shareImage(call: call, result: result)
    case "saveImageToGallery":
      saveImageToGallery(call: call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func shareImage(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let imagePath = args["imagePath"] as? String,
          let subject = args["subject"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      return
    }

    guard let image = UIImage(contentsOfFile: imagePath) else {
      result(FlutterError(code: "IMAGE_NOT_FOUND", message: "Image not found at path: \(imagePath)", details: nil))
      return
    }

    DispatchQueue.main.async {
      let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
      activityViewController.setValue(subject, forKey: "subject")
      
      if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
        rootViewController.present(activityViewController, animated: true) {
          result(true)
        }
      } else {
        result(FlutterError(code: "NO_ROOT_VIEW_CONTROLLER", message: "No root view controller found", details: nil))
      }
    }
  }

  private func saveImageToGallery(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let imagePath = args["imagePath"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
      return
    }

    guard let image = UIImage(contentsOfFile: imagePath) else {
      result(FlutterError(code: "IMAGE_NOT_FOUND", message: "Image not found at path: \(imagePath)", details: nil))
      return
    }

    PHPhotoLibrary.requestAuthorization { status in
      if status == .authorized {
        PHPhotoLibrary.shared().performChanges({
          PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
          DispatchQueue.main.async {
            if success {
              result(true)
            } else {
              result(FlutterError(code: "SAVE_FAILED", message: error?.localizedDescription ?? "Failed to save image", details: nil))
            }
          }
        }
      } else {
        DispatchQueue.main.async {
          result(FlutterError(code: "PERMISSION_DENIED", message: "Photo library permission denied", details: nil))
        }
      }
    }
  }
}
