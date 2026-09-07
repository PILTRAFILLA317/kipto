import Flutter
import EventKit
import EventKitUI
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var calendarAdapter: CalendarEventEditorAdapter?
  private let sharedCaptureAdapter = SharedCaptureAdapter()
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "KiptoCalendarAdapter"
    ) else { return }
    let adapter = CalendarEventEditorAdapter()
    calendarAdapter = adapter
    FlutterMethodChannel(
      name: "app.kipto/calendar",
      binaryMessenger: registrar.messenger()
    ).setMethodCallHandler(adapter.handle)
    FlutterMethodChannel(name: "app.kipto/capture", binaryMessenger: registrar.messenger())
      .setMethodCallHandler(sharedCaptureAdapter.handle)
  }
}

private final class CalendarEventEditorAdapter: NSObject, EKEventEditViewDelegate {
  private let eventStore = EKEventStore()
  private var pendingResult: FlutterResult?

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "presentCalendarEventDraft" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard pendingResult == nil,
          let values = call.arguments as? [String: Any],
          let title = values["title"] as? String,
          let startMilliseconds = values["startAtMilliseconds"] as? NSNumber,
          let endMilliseconds = values["endAtMilliseconds"] as? NSNumber,
          !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
          endMilliseconds.int64Value > startMilliseconds.int64Value else {
      result(FlutterError(code: "invalidData", message: "Invalid calendar event draft", details: nil))
      return
    }
    pendingResult = result
    let present = { [weak self] in
      self?.presentEditor(values: values)
    }
    if #available(iOS 17.0, *) {
      present()
    } else {
      eventStore.requestAccess(to: .event) { [weak self] granted, _ in
        DispatchQueue.main.async {
          guard granted else {
            self?.finish("permissionDenied")
            return
          }
          present()
        }
      }
    }
  }

  private func presentEditor(values: [String: Any]) {
    guard let presenter = topViewController() else {
      finish("unavailable")
      return
    }
    let event = EKEvent(eventStore: eventStore)
    event.title = values["title"] as? String
    event.startDate = Date(
      timeIntervalSince1970: (values["startAtMilliseconds"] as! NSNumber).doubleValue / 1000
    )
    event.endDate = Date(
      timeIntervalSince1970: (values["endAtMilliseconds"] as! NSNumber).doubleValue / 1000
    )
    event.isAllDay = values["allDay"] as? Bool ?? false
    if let identifier = values["timeZone"] as? String {
      event.timeZone = TimeZone(identifier: identifier)
    }
    event.location = values["location"] as? String
    event.notes = values["notes"] as? String
    if let rawURL = values["url"] as? String {
      event.url = URL(string: rawURL)
    }
    let editor = EKEventEditViewController()
    editor.eventStore = eventStore
    editor.event = event
    editor.editViewDelegate = self
    presenter.present(editor, animated: true)
  }

  func eventEditViewController(
    _ controller: EKEventEditViewController,
    didCompleteWith action: EKEventEditViewAction
  ) {
    controller.dismiss(animated: true) { [weak self] in
      self?.finish(action == .saved ? "saved" : "cancelled")
    }
  }

  private func finish(_ value: String) {
    let result = pendingResult
    pendingResult = nil
    result?(value)
  }

  private func topViewController(
    from root: UIViewController? = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }?
      .rootViewController
  ) -> UIViewController? {
    if let navigation = root as? UINavigationController {
      return topViewController(from: navigation.visibleViewController)
    }
    if let tabs = root as? UITabBarController {
      return topViewController(from: tabs.selectedViewController)
    }
    if let presented = root?.presentedViewController {
      return topViewController(from: presented)
    }
    return root
  }
}
