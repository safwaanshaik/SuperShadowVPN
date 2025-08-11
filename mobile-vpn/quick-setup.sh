#!/bin/bash

# Quick WireGuard setup for mobile testing
echo "Quick SuperShadowVPN setup for mobile..."

# Install WireGuard (fastest option)
sudo apt-get update && sudo apt-get install -y wireguard qrencode

# Generate keys
SERVER_PRIVATE=$(wg genkey)
SERVER_PUBLIC=$(echo $SERVER_PRIVATE | wg pubkey)
CLIENT_PRIVATE=$(wg genkey)
CLIENT_PUBLIC=$(echo $CLIENT_PRIVATE | wg pubkey)

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)

# Create server config
sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOF
[Interface]
PrivateKey = $SERVER_PRIVATE
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUBLIC
AllowedIPs = 10.0.0.2/32
EOF

# Create client config
cat > client.conf <<EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = $SERVER_PUBLIC
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Enable forwarding
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Start VPN
sudo wg-quick up wg0

echo ""
echo "🚀 SuperShadowVPN is ready!"
echo ""
echo "📱 On your phone:"
echo "1. Install WireGuard app from App Store/Play Store"
echo "2. Scan this QR code:"
echo ""
qrencode -t ansiutf8 < client.conf
echo ""
echo "Or manually add VPN with these details:"
echo "Server: $SERVER_IP:51820"
echo "Config file: ./client.conf"