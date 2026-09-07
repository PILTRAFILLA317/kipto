import Foundation
import UIKit
import ImageIO
import PDFKit

/// Foreground-only, bounded analysis. Output is a preview; actions are reviewed
/// in Flutter through its full shared contract validator after durable import.
enum ShareAnalysis {
  static func prepare(manifest: ShareManifest, store: ShareStore) throws -> Data {
    guard manifest.attachments.count <= 1 else { throw ShareFailure.invalid }
    var texts: [[String: Any]] = []
    var images: [[String: Any]] = []
    if let source = manifest.attachments.first {
      let url = store.incoming.appendingPathComponent(source.relativePath)
      if source.mimeType == "application/pdf" {
        guard let pdf = PDFDocument(url: url), !pdf.isLocked, (1...10).contains(pdf.pageCount) else { throw ShareFailure.tooLarge }
        for index in 0..<pdf.pageCount {
          guard let page = pdf.page(at: index) else { throw ShareFailure.invalid }
          let text = (page.string ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
          if !text.isEmpty { texts.append(["page": index+1, "text": text]) }
        }
        if texts.count != pdf.pageCount {
          texts = []
          for index in 0..<pdf.pageCount {
            guard let page = pdf.page(at: index), let data = page.thumbnail(of: CGSize(width: 1200, height: 1600), for: .mediaBox).jpegData(compressionQuality: 0.8) else { throw ShareFailure.invalid }
            images.append(["page": index+1,"mimeType":"image/jpeg","base64":data.base64EncodedString()])
          }
        }
      } else {
        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, [kCGImageSourceCreateThumbnailFromImageAlways:true,
                kCGImageSourceThumbnailMaxPixelSize:1600,kCGImageSourceCreateThumbnailWithTransform:true] as CFDictionary),
              let data = UIImage(cgImage:image).jpegData(compressionQuality:0.85) else { throw ShareFailure.invalid }
        images = [["page":1,"mimeType":"image/jpeg","base64":data.base64EncodedString()]]
      }
    } else if let text = manifest.contextText { texts = [["page":1,"text":text]] }
    let textLength = texts.reduce(0) { $0 + (($1["text"] as? String)?.utf16.count ?? 0) }
    guard textLength <= 60000 else { throw ShareFailure.tooLarge }
    let count = max(texts.count, images.count)
    guard count > 0 else { throw ShareFailure.invalid }
    let body: [String:Any] = ["requestVersion":1,"requestId":UUID().uuidString.lowercased(),"captureId":manifest.captureId,
      "sourceId":manifest.attachments.first?.sourceId ?? manifest.captureId,"sourceRevision":1,
      "locale":Locale.current.languageCode == "en" ? "en":"es","userTimeZone":TimeZone.current.identifier,
      "importedAt":ISO8601DateFormatter().string(from:Date()),"knownDocumentContext":NSNull(),
      "input":["type":images.isEmpty ? "text":"imagePages","textPages":texts,"imagePages":images],
      "coverage":["totalPagesKnown":count,"analyzedPages":Array(1...count),"isPartial":false]]
    let data = try JSONSerialization.data(withJSONObject:body,options:[.sortedKeys])
    guard data.count <= 8*1024*1024 else { throw ShareFailure.tooLarge }
    return data
  }
  static func run(payload: Data, session: ShareSession) async throws -> (Data,String) {
    guard let url = URL(string:session.apiURL + "/functions/v1/analyze-source") else { throw ShareFailure.configuration }
    var request = URLRequest(url:url,timeoutInterval:35)
    request.httpMethod = "POST"; request.httpBody = payload
    request.setValue("application/json", forHTTPHeaderField:"Content-Type")
    request.setValue("Bearer \(session.accessToken)",forHTTPHeaderField:"Authorization")
    request.setValue(session.publicKey,forHTTPHeaderField:"apikey")
    let configuration = URLSessionConfiguration.ephemeral
    configuration.timeoutIntervalForResource = 40
    let client = URLSession(configuration:configuration,delegate:NoRedirectDelegate(),delegateQueue:nil)
    defer { client.invalidateAndCancel() }
    let (stream,response) = try await client.bytes(for:request)
    guard let http = response as? HTTPURLResponse, http.statusCode == 200,
          http.url?.host == url.host else { throw ShareFailure.unavailable }
    var data = Data()
    for try await byte in stream {
      try Task.checkCancellation()
      guard data.count < 262144 else { throw ShareFailure.tooLarge }
      data.append(byte)
    }
    let original = try JSONSerialization.jsonObject(with:payload) as? [String:Any]
    guard let envelope = try JSONSerialization.jsonObject(with:data) as? [String:Any],
      envelope["schemaVersion"] as? Int == 1, envelope["requestId"] as? String == original?["requestId"] as? String,
      let output = envelope["output"] as? [String:Any], output["schemaVersion"] as? Int == 1,
      output["sourceRevision"] as? Int == 1, let summary = output["summary"] as? String, summary.utf16.count <= 300,
      let title = output["title"] as? String, title.utf16.count <= 100,
      let facts = output["facts"] as? [Any], facts.count <= 12,
      let suggestions = output["suggestions"] as? [Any], suggestions.count <= 6 else { throw ShareFailure.invalid }
    return (data,summary)
  }
}
