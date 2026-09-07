import Flutter
import Foundation

final class SharedCaptureAdapter {
  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "excludeOriginalsFromBackup" {
      do {
        guard let path = call.arguments as? String, let base = FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask).first,
          path.hasPrefix(base.path + "/") else { throw ShareFailure.invalid }
        var url = URL(fileURLWithPath:path,isDirectory:true)
        try FileManager.default.createDirectory(at:url,withIntermediateDirectories:true)
        var values = URLResourceValues(); values.isExcludedFromBackup = true
        try url.setResourceValues(values); result(nil)
      } catch { result(FlutterError(code:"backupConfiguration",message:"Local backup exclusion unavailable",details:nil)) }
      return
    }
    if call.method == "clearSession" {
      do { try ShareSession.clear(); result(nil) } catch { result(FlutterError(code:"keychainUnavailable",message:"Shared session unavailable",details:nil)) }
      return
    }
    if call.method == "setAnalysisSession" {
      do {
        guard let values = call.arguments as? [String:Any] else { throw ShareFailure.invalid }
        let data = try JSONSerialization.data(withJSONObject:values)
        try JSONDecoder().decode(ShareSession.self,from:data).save()
        result(nil)
      } catch { result(FlutterError(code:"keychainUnavailable",message:"Shared session unavailable",details:nil)) }
      return
    }
    guard let store = try? ShareStore() else {
      // App Group setup is optional for ordinary Flutter capture. Returning
      // nil preserves its existing installation-scoped fallback.
      result(nil)
      return
    }
    do {
      switch call.method {
      case "localScope": result(try store.localScope())
      case "incomingDirectory": result(store.incoming.path)
      case "setReducedMotion":
        guard let reduced = call.arguments as? Bool else { throw ShareFailure.invalid }
        try store.setReducedMotion(reduced)
        result(nil)
      case "setScope":
        guard let scope = call.arguments as? String else { throw ShareFailure.invalid }
        let previous = try store.readScope()
        try store.setScope(ShareScope(accountScopeId: scope,
          analysisConsent: previous.accountScopeId == scope && previous.analysisConsent))
        result(nil)
      default: result(FlutterMethodNotImplemented)
      }
    } catch { result(FlutterError(code: "captureUnavailable", message: "Shared capture unavailable", details: nil)) }
  }
}
