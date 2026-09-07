import Foundation
import UniformTypeIdentifiers
import ImageIO
import PDFKit

enum ShareFailure: Error, Equatable { case configuration, invalid, tooLarge, unavailable, accountChanged }

struct SharedSource: Codable, Identifiable {
  var id: String { sourceId }
  let sourceId: String
  let relativePath: String
  let originalName: String
  let mimeType: String
  let byteSize: Int
}

// Native capture writes this contract; Flutter validates and imports it.
struct ShareManifest: Encodable {
  let manifestVersion = 1
  let state = "ready"
  let platform = "ios"
  let captureId: String
  let accountScopeId: String
  var attachments: [SharedSource]
  var contextText: String?
  var title: String?
}

struct ShareScope: Codable {
  let accountScopeId: String
  var analysisConsent: Bool = false
}

/// Shared metadata is coordinated and atomically replaced. Each capture owns
/// a unique directory; readers only import its final manifest.json.
final class ShareStore {
  static let maxBytes = 20 * 1024 * 1024
  let root: URL
  let incoming: URL
  init() throws {
    guard let group = Bundle.main.object(forInfoDictionaryKey: "KiptoAppGroup") as? String,
          group.hasPrefix("group."), !group.contains("$("),
          let root = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: group) else {
      throw ShareFailure.configuration
    }
    self.root = root
    incoming = root.appendingPathComponent("incoming", isDirectory: true)
    try FileManager.default.createDirectory(at: incoming, withIntermediateDirectories: true)
    var location = incoming
    var values = URLResourceValues(); values.isExcludedFromBackup = true
    try location.setResourceValues(values)
  }

  func readScope() throws -> ShareScope {
    try coordinated {
      let file = root.appendingPathComponent("scope.json")
      if let data = try? Data(contentsOf: file), let scope = try? JSONDecoder().decode(ShareScope.self, from: data) {
        return scope
      }
      let local = try localScopeLocked()
      return ShareScope(accountScopeId: local)
    }
  }
  func localScope() throws -> String { try coordinated { try localScopeLocked() } }
  private func localScopeLocked() throws -> String {
    let file = root.appendingPathComponent("installation.txt")
    if let value = try? String(contentsOf: file, encoding: .utf8), UUID(uuidString: value) != nil { return "local:\(value)" }
    let id = UUID().uuidString.lowercased()
    try Data(id.utf8).write(to: file, options: .atomic)
    return "local:\(id)"
  }
  func setScope(_ value: ShareScope) throws {
    guard value.accountScopeId.count <= 128,
          UUID(uuidString: value.accountScopeId.replacingOccurrences(of: "local:", with: "")) != nil else { throw ShareFailure.invalid }
    try coordinated { try JSONEncoder().encode(value).write(to: root.appendingPathComponent("scope.json"), options: .atomic) }
  }
  func reducedMotion() throws -> Bool {
    try coordinated {
      guard let data = try? Data(contentsOf: root.appendingPathComponent("reduced-motion.json")),
            let value = try? JSONDecoder().decode(Bool.self, from: data) else { return true }
      return value
    }
  }
  func setReducedMotion(_ value: Bool) throws {
    try coordinated {
      try JSONEncoder().encode(value).write(to: root.appendingPathComponent("reduced-motion.json"), options: .atomic)
    }
  }
  func draftDirectory(id: String) throws -> URL {
    guard UUID(uuidString: id) != nil else { throw ShareFailure.invalid }
    let directory = incoming.appendingPathComponent(id, isDirectory: true)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false)
    try Data(Date().description.utf8).write(to: directory.appendingPathComponent("copying"), options: .atomic)
    return directory
  }
  func publish(_ manifest: ShareManifest) throws {
    guard manifest.attachments.count <= 5, (manifest.contextText?.count ?? 0) <= 60000,
          !manifest.attachments.isEmpty || !(manifest.contextText?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true) else { throw ShareFailure.invalid }
    try coordinated {
      let scopeFile = root.appendingPathComponent("scope.json")
      let current = try ((try? JSONDecoder().decode(ShareScope.self, from: Data(contentsOf: scopeFile)))?.accountScopeId ?? localScopeLocked())
      guard current == manifest.accountScopeId else { throw ShareFailure.accountChanged }
      let directory = incoming.appendingPathComponent(manifest.captureId)
      let encoded = try JSONEncoder().encode(manifest)
      try encoded.write(to: directory.appendingPathComponent("manifest.json"), options: .atomic)
      try? FileManager.default.removeItem(at: directory.appendingPathComponent("copying"))
    }
  }
  func fail(id: String) {
    guard UUID(uuidString: id) != nil else { return }
    try? Data().write(to: incoming.appendingPathComponent(id).appendingPathComponent("failed"), options: .atomic)
  }
  private func coordinated<T>(_ work: () throws -> T) throws -> T {
    var coordinationError: NSError?
    var outcome: Result<T, Error>?
    NSFileCoordinator().coordinate(writingItemAt: root, options: .forMerging, error: &coordinationError) { _ in
      outcome = Result { try work() }
    }
    if let error = coordinationError { throw error }
    guard let outcome else { throw ShareFailure.unavailable }
    return try outcome.get()
  }

  /// Copy inside the NSItemProvider callback: its temporary URL expires when
  /// that callback returns. Never retain or hand the provider URL to Flutter.
  func copy(_ provider: NSItemProvider, type: String, directory: URL, captureId: String) async throws -> SharedSource {
    let suggestedName = provider.suggestedName
    return try await withCheckedThrowingContinuation { continuation in
      provider.loadFileRepresentation(forTypeIdentifier: type) { url, error in
        guard error == nil, let url else { continuation.resume(throwing: ShareFailure.unavailable); return }
        do {
          let id = UUID().uuidString.lowercased()
          let destination = directory.appendingPathComponent(id)
          let input = InputStream(url: url)
          let output = OutputStream(url: destination, append: false)
          guard let input, let output else { throw ShareFailure.unavailable }
          input.open(); output.open()
          defer { input.close(); output.close() }
          var buffer = [UInt8](repeating: 0, count: 64 * 1024)
          var total = 0
          while true {
            let count = input.read(&buffer, maxLength: buffer.count)
            if count == 0 { break }
            guard count > 0 else { throw ShareFailure.unavailable }
            total += count
            guard total <= Self.maxBytes else { throw ShareFailure.tooLarge }
            var offset = 0
            try buffer.withUnsafeBufferPointer { pointer in
              while offset < count {
                let written = output.write(pointer.baseAddress!.advanced(by: offset), maxLength: count - offset)
                guard written > 0 else { throw ShareFailure.unavailable }
                offset += written
              }
            }
          }
          guard total > 0 else { throw ShareFailure.invalid }
          output.close()
          let handle = try FileHandle(forWritingTo: destination)
          try handle.synchronize(); try handle.close()
          let mime = try Self.validatedMime(destination)
          let name = String((suggestedName ?? url.lastPathComponent).prefix(512))
          continuation.resume(returning: SharedSource(sourceId: id, relativePath: "\(captureId)/\(id)",
            originalName: name.isEmpty ? "Documento" : name, mimeType: mime, byteSize: total))
        } catch { continuation.resume(throwing: error) }
      }
    }
  }

  static func validatedMime(_ url: URL) throws -> String {
    let handle = try FileHandle(forReadingFrom: url)
    let header = try handle.read(upToCount: 32) ?? Data()
    try handle.close()
    let bytes = [UInt8](header)
    let mime: String
    if header.starts(with: Data("%PDF-".utf8)) {
      guard let pdf = PDFDocument(url: url), !pdf.isLocked, pdf.pageCount > 0 else { throw ShareFailure.invalid }
      return "application/pdf"
    } else if bytes.starts(with: [137,80,78,71,13,10,26,10]) { mime = "image/png" }
    else if bytes.starts(with: [255,216,255]) { mime = "image/jpeg" }
    else if bytes.count >= 12 && String(bytes: bytes[0..<4], encoding: .ascii) == "RIFF" && String(bytes: bytes[8..<12], encoding: .ascii) == "WEBP" { mime = "image/webp" }
    else if bytes.count >= 12 && String(bytes: bytes[4..<8], encoding: .ascii) == "ftyp" && ["heic","heix","hevc","hevx","mif1","msf1"].contains(String(bytes: bytes[8..<12], encoding: .ascii) ?? "") { mime = "image/heic" }
    else { throw ShareFailure.invalid }
    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
          let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
          let width = properties[kCGImagePropertyPixelWidth] as? Int,
          let height = properties[kCGImagePropertyPixelHeight] as? Int,
          width > 0, height > 0, width <= 40000000 / height,
          CGImageSourceCreateThumbnailAtIndex(source, 0, [kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: 256, kCGImageSourceCreateThumbnailWithTransform: true] as CFDictionary) != nil else { throw ShareFailure.invalid }
    return mime
  }
}
