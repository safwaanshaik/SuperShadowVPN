import SwiftUI
import NetworkExtension

public struct SuperShadowVPNView: View {
    @StateObject private var vpnManager = SuperShadowVPNManager()
    @State private var serverAddress = "your-server.com"
    @State private var serverPort = "8080"
    @State private var password = "supersecretkey32byteslongformax"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(vpnManager.isConnected ? .green : .gray)
                
                Text("SuperShadowVPN")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    TextField("Server Address", text: $serverAddress)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Port", text: $serverPort)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Button(action: {
                    if vpnManager.isConnected {
                        vpnManager.disconnect()
                    } else {
                        Task {
                            await connectVPN()
                        }
                    }
                }) {
                    Text(vpnManager.isConnected ? "Disconnect" : "Connect")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vpnManager.isConnected ? Color.red : Color.blue)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("SuperShadowVPN")
            .alert("VPN Status", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var statusText: String {
        switch vpnManager.status {
        case .invalid: return "Not configured"
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting..."
        case .connected: return "Connected"
        case .reasserting: return "Reconnecting..."
        case .disconnecting: return "Disconnecting..."
        @unknown default: return "Unknown"
        }
    }
    
    private func connectVPN() async {
        do {
            try await vpnManager.setup(
                serverAddress: serverAddress,
                serverPort: Int(serverPort) ?? 8080,
                password: password
            )
            try await vpnManager.connect()
        } catch {
            alertMessage = "Failed to connect: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}