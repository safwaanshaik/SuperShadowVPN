#!/bin/bash

echo "Setting up WireGuard VPN server for mobile..."

# Install WireGuard
sudo apt-get update
sudo apt-get install -y wireguard qrencode

# Generate server keys
cd /etc/wireguard
sudo wg genkey | sudo tee privatekey | sudo wg pubkey | sudo tee publickey
SERVER_PRIVATE_KEY=$(sudo cat privatekey)
SERVER_PUBLIC_KEY=$(sudo cat publickey)

# Generate client keys
sudo wg genkey | sudo tee client_privatekey | sudo wg pubkey | sudo tee client_publickey
CLIENT_PRIVATE_KEY=$(sudo cat client_privatekey)
CLIENT_PUBLIC_KEY=$(sudo cat client_publickey)

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)

# Create server config
sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOF
[Interface]
PrivateKey = $SERVER_PRIVATE_KEY
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
EOF

# Create client config
tee ~/client.conf > /dev/null <<EOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Start WireGuard
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# Generate QR code for mobile
qrencode -t ansiutf8 < ~/client.conf

echo ""
echo "🚀 WireGuard VPN Server is ready!"
echo "📱 Scan QR code above with WireGuard mobile app"
echo "📄 Or send ~/client.conf to your phone"
echo ""
echo "Server: $SERVER_IP:51820"
echo "Client config: ~/client.conf"