import Foundation
import Security

/// Only the current access credential is shared. No refresh-token ownership
/// exists in the extension, and no credential is written to App Group files.
struct ShareSession: Codable {
  let userId: String
  let accessToken: String
  let expiresAt: Double
  let apiURL: String
  let publicKey: String
  let consent: Bool
  static func query() throws -> [String: Any] {
    guard let group = Bundle.main.object(forInfoDictionaryKey: "KiptoKeychainGroup") as? String,
          !group.isEmpty, !group.contains("$("), !group.hasSuffix(".") else { throw ShareFailure.configuration }
    return [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: "kipto.share.analysis.v1",
      kSecAttrAccount as String: "current", kSecAttrAccessGroup as String: group]
  }
  static func clear() throws {
    let status = SecItemDelete(try query() as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else { throw ShareFailure.unavailable }
  }
  func save() throws {
    guard UUID(uuidString: userId) != nil, accessToken.utf8.count < 16384,
          let url = URL(string: apiURL), url.scheme == "https", url.host != nil else { throw ShareFailure.invalid }
    var query = try Self.query()
    let value = try JSONEncoder().encode(self)
    let updated = SecItemUpdate(query as CFDictionary, [kSecValueData as String: value] as CFDictionary)
    if updated == errSecSuccess { return }
    guard updated == errSecItemNotFound else { throw ShareFailure.unavailable }
    query[kSecValueData as String] = value
    query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    guard SecItemAdd(query as CFDictionary, nil) == errSecSuccess else { throw ShareFailure.unavailable }
  }
  static func read(scope: String) throws -> ShareSession {
    var query = try query()
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    var result: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
          let data = result as? Data else { throw ShareFailure.unavailable }
    let session = try JSONDecoder().decode(ShareSession.self, from: data)
    guard session.userId == scope, session.consent, session.expiresAt > Date().timeIntervalSince1970 + 45 else { throw ShareFailure.unavailable }
    return session
  }
}
