import NetworkExtension
import Crypto
import Foundation

public class SuperShadowVPNManager: ObservableObject {
    private let manager = NEVPNManager.shared()
    @Published public var isConnected = false
    @Published public var status: NEVPNStatus = .invalid
    
    public init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(statusChanged),
            name: .NEVPNStatusDidChange,
            object: nil
        )
    }
    
    public func setup(serverAddress: String, serverPort: Int, password: String) async throws {
        let protocol = NEVPNProtocolIPSec()
        protocol.serverAddress = serverAddress
        protocol.username = "supershadow"
        protocol.passwordReference = try savePassword(password)
        protocol.authenticationMethod = .sharedSecret
        protocol.sharedSecretReference = try saveSharedSecret("supershadowvpn")
        protocol.useExtendedAuthentication = true
        
        manager.protocolConfiguration = protocol
        manager.localizedDescription = "SuperShadowVPN"
        manager.isEnabled = true
        
        try await manager.saveToPreferences()
        try await manager.loadFromPreferences()
    }
    
    public func connect() async throws {
        try await manager.connection.startVPNTunnel()
    }
    
    public func disconnect() {
        manager.connection.stopVPNTunnel()
    }
    
    @objc private func statusChanged() {
        DispatchQueue.main.async {
            self.status = self.manager.connection.status
            self.isConnected = self.status == .connected
        }
    }
    
    private func savePassword(_ password: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "supershadowvpn_password",
            kSecValueData as String: password.data(using: .utf8)!,
            kSecReturnPersistentRef as String: true
        ]
        
        var result: CFTypeRef?
        let status = SecItemAdd(query as CFDictionary, &result)
        
        if status == errSecDuplicateItem {
            SecItemDelete(query as CFDictionary)
            SecItemAdd(query as CFDictionary, &result)
        }
        
        return result as! Data
    }
    
    private func saveSharedSecret(_ secret: String) throws -> Data {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "supershadowvpn_secret",
            kSecValueData as String: secret.data(using: .utf8)!,
            kSecReturnPersistentRef as String: true
        ]
        
        var result: CFTypeRef?
        SecItemAdd(query as CFDictionary, &result)
        return result as! Data
    }
}