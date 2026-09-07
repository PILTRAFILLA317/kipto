import UIKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class ShareViewController: UIViewController {
  private var model: ShareViewModel?
  override func viewDidLoad() {
    super.viewDidLoad()
    let model = ShareViewModel(context: extensionContext)
    self.model = model
    let host = UIHostingController(rootView: ShareView(model: model))
    addChild(host)
    host.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(host.view)
    NSLayoutConstraint.activate([
      host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      host.view.topAnchor.constraint(equalTo: view.topAnchor),
      host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
    host.didMove(toParent: self)
    model.prepare()
  }
}

@MainActor
final class ShareViewModel: ObservableObject {
  @Published var title = ""
  @Published var names: [String] = []
  @Published var progress = 0
  @Published var total = 0
  @Published var ready = false
  @Published var saving = false
  @Published var saved = false
  @Published var reducedMotion = true
  @Published var analyzing = false
  @Published var summary: String?
  private var analysisTask: Task<Void,Never>?
  @Published var message: String?
  private let context: NSExtensionContext?
  private var closing = false
  private var task: Task<Void, Never>?
  private var store: ShareStore?
  private var manifest: ShareManifest?
  private let captureId = UUID().uuidString.lowercased()
  init(context: NSExtensionContext?) { self.context = context }

  func prepare() {
    task = Task {
      do {
        let store = try ShareStore()
        self.store = store
        reducedMotion = (try? store.reducedMotion()) ?? true
        let scope = try store.readScope()
        let directory = try store.draftDirectory(id: captureId)
        let items = (context?.inputItems as? [NSExtensionItem]) ?? []
        let providers = items.flatMap { $0.attachments ?? [] }
        let supported = [UTType.pdf.identifier, UTType.jpeg.identifier, UTType.png.identifier,
          UTType.heic.identifier, UTType.heif.identifier, UTType.webP.identifier, UTType.image.identifier]
        let files = providers.compactMap { provider -> (NSItemProvider, String)? in
          guard let type = supported.first(where: { provider.hasItemConformingToTypeIdentifier($0) }) else { return nil }
          return (provider, type)
        }
        guard files.count <= 5 else { throw ShareFailure.tooLarge }
        total = files.count
        var sources: [SharedSource] = []
        for (provider, type) in files {
          try Task.checkCancellation()
          let source = try await store.copy(provider, type: type, directory: directory, captureId: captureId)
          sources.append(source); names.append(source.originalName); progress += 1
          // A terminated copy exposes only completed files as an unconfirmed draft.
          let partial = ShareManifest(captureId: captureId, accountScopeId: scope.accountScopeId,
            attachments: sources, contextText: nil, title: nil)
          try JSONEncoder().encode(partial).write(to: directory.appendingPathComponent("draft.json"), options: .atomic)
        }
        var pieces: [String] = items.compactMap { $0.attributedContentText?.string }
        for provider in providers where !supported.contains(where: { provider.hasItemConformingToTypeIdentifier($0) }) {
          if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            let text = try await loadText(provider, type: UTType.plainText.identifier)
            if !pieces.contains(text) { pieces.append(text) }
          } else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            let text = try await loadText(provider, type: UTType.url.identifier)
            if !pieces.contains(text) { pieces.append(text) }
          } else { throw ShareFailure.invalid }
        }
        try Task.checkCancellation()
        let text = pieces.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count <= 60000, !sources.isEmpty || !text.isEmpty else { throw ShareFailure.invalid }
        let manifest = ShareManifest(captureId: captureId, accountScopeId: scope.accountScopeId,
          attachments: sources, contextText: text.isEmpty ? nil : text, title: nil)
        self.manifest = manifest
        try JSONEncoder().encode(manifest).write(to: directory.appendingPathComponent("draft.json"), options: .atomic)
        ready = true
      } catch {
        store?.fail(id: captureId)
        message = NSLocalizedString(error is ShareFailure && (error as? ShareFailure) == .configuration ? "share.setup" : "share.failed", comment: "")
      }
    }
  }
  private func loadText(_ provider: NSItemProvider, type: String) async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
      provider.loadItem(forTypeIdentifier: type, options: nil) { item, error in
        guard error == nil else { continuation.resume(throwing: ShareFailure.unavailable); return }
        let text = (item as? String) ?? (item as? URL)?.absoluteString
        guard let text, text.count <= 60000 else { continuation.resume(throwing: ShareFailure.invalid); return }
        continuation.resume(returning: text)
      }
    }
  }
  func analyze() {
    guard ready, !saving, !saved, !analyzing, let manifest, let store else { return }
    analyzing = true
    analysisTask = Task {
      defer { analyzing = false }
      do {
        let session = try ShareSession.read(scope:manifest.accountScopeId)
        let directory = store.incoming.appendingPathComponent(captureId)
        let requestFile = directory.appendingPathComponent("analysis-request.json")
        let payload: Data
        if FileManager.default.fileExists(atPath:requestFile.path) { payload = try Data(contentsOf:requestFile) }
        else {
          payload = try await Task.detached { try ShareAnalysis.prepare(manifest:manifest,store:store) }.value
          try payload.write(to:requestFile,options:.atomic)
        }
        try Task.checkCancellation()
        let (envelope, summary) = try await ShareAnalysis.run(payload:payload,session:session)
        try Task.checkCancellation()
        _ = try ShareSession.read(scope:manifest.accountScopeId)
        guard try store.readScope().accountScopeId == manifest.accountScopeId else { throw ShareFailure.accountChanged }
        try envelope.write(to:directory.appendingPathComponent("analysis-envelope.json"),options:.atomic)
        self.summary = summary
      } catch {
        // Cancelling analysis to save/close must not replace the saved state.
        if !Task.isCancelled && !saved {
          message = NSLocalizedString("share.analysisPending",comment:"")
        }
      }
    }
  }
  func save() {
    guard ready, !saving, !saved, var manifest, let store else { return }
    saving = true
    analysisTask?.cancel()
    do {
      let value = title.trimmingCharacters(in: .whitespacesAndNewlines)
      guard value.count <= 100 else { throw ShareFailure.invalid }
      manifest.title = value.isEmpty ? nil : value
      try store.publish(manifest)
      // Confirm only after the durable manifest exists. Closing is available
      // immediately; no timer or animation completion gates the user's return.
      reducedMotion = (try? store.reducedMotion()) ?? true
      saved = true
      saving = false
      message = nil
      names = []
      summary = nil
      UIAccessibility.post(notification: .announcement,
        argument: NSLocalizedString("share.saved", comment: ""))
    } catch {
      saving = false
      message = NSLocalizedString("share.failed", comment: "")
    }
  }
  func finish() {
    guard saved, !closing else { return }
    closing = true
    context?.completeRequest(returningItems: nil)
  }
  func cancel() {
    if saved { finish(); return }
    guard !closing else { return }
    closing = true
    task?.cancel()
    analysisTask?.cancel()
    context?.cancelRequest(withError: NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError))
  }
}

private struct ShareView: View {
  @ObservedObject var model: ShareViewModel
  private let background = Color(red: 0.047, green: 0.047, blue: 0.063)
  private let accent = Color(red: 0.71, green: 0.40, blue: 0.64)
  var body: some View {
    ZStack {
      background.ignoresSafeArea()
      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          Text("Kipto").font(.system(.title2, design: .rounded).weight(.semibold)).foregroundColor(accent)
          Text("share.title").font(.largeTitle.bold()).accessibilityAddTraits(.isHeader)
          Text("share.body").foregroundColor(.white.opacity(0.75))
          if !model.ready && model.message == nil {
            ProgressView(value: Double(model.progress), total: Double(max(1, model.total))).tint(accent)
              .accessibilityLabel(Text("share.copying"))
            Text("share.copying")
          }
          ForEach(Array(model.names.enumerated()), id: \.offset) { _, name in
            Label(name, systemImage: "doc").lineLimit(3)
          }
          if model.total > 1 { Text("share.multiple").font(.callout) }
          if model.total <= 1 && !model.saved {
            TextField("share.optionalTitle", text: $model.title).textFieldStyle(.plain)
              .padding(16).background(Color.white.opacity(0.08)).cornerRadius(16)
              .disabled(model.saving)
          }
          if model.ready && model.total <= 1 && !model.saved {
            Button(action:model.analyze) { Text(model.analyzing ? "share.analyzing":"share.analyze") }
              .disabled(model.analyzing || model.saving)
            if let summary = model.summary { Text(summary).textSelection(.enabled) }
            Text("share.reviewInApp").font(.callout).foregroundColor(.white.opacity(0.75))
          }
          if let message = model.message { Text(message).foregroundColor(Color(red: 0.96, green: 0.69, blue: 0.73)) }
          if model.saved {
            HStack(alignment: .top, spacing: 12) {
              ShareSuccessMark(reduceLocally: model.reducedMotion).foregroundColor(accent).accessibilityHidden(true)
              Text("share.saved")
            }
            Button("share.done", action: model.finish)
              .font(.headline).frame(maxWidth: .infinity).padding(18)
              .background(accent).foregroundColor(.white).cornerRadius(22)
          } else {
            Button(action: model.save) {
            Text("share.save").font(.headline).frame(maxWidth: .infinity).padding(18)
              .background(accent).foregroundColor(.white).cornerRadius(22)
          }.disabled(!model.ready || model.saving).opacity(model.ready ? 1 : 0.5)
          Button("share.cancel", action: model.cancel).frame(maxWidth: .infinity).foregroundColor(.white.opacity(0.8))
          }
        }.padding(28)
      }
    }.foregroundColor(.white).preferredColorScheme(.dark)
  }
}

private struct ShareSuccessMark: View {
  @Environment(\.accessibilityReduceMotion) private var reducedMotion
  let reduceLocally: Bool
  @State private var drawn = false
  var body: some View {
    ZStack {
      Circle().stroke(lineWidth: 2)
      ShareCheckPath().trim(from: 0, to: reducedMotion || reduceLocally || drawn ? 1 : 0)
        .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
    }.frame(width: 24, height: 24)
      .onAppear {
        withAnimation(reducedMotion || reduceLocally ? nil : .easeOut(duration: 0.24)) { drawn = true }
      }
  }
}

private struct ShareCheckPath: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.move(to: CGPoint(x: rect.width * 0.25, y: rect.height * 0.51))
    path.addLine(to: CGPoint(x: rect.width * 0.44, y: rect.height * 0.69))
    path.addLine(to: CGPoint(x: rect.width * 0.76, y: rect.height * 0.34))
    return path
  }
}
