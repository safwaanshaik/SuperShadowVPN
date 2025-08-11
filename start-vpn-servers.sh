#!/bin/bash

echo "Starting SuperShadowVPN servers for WireGuard and OpenVPN..."

# Install both
sudo apt-get update
sudo apt-get install -y wireguard openvpn easy-rsa qrencode

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)
echo "Server IP: $SERVER_IP"

# === WireGuard Setup ===
echo "Setting up WireGuard..."

# Generate WireGuard keys
WG_SERVER_PRIVATE=$(wg genkey)
WG_SERVER_PUBLIC=$(echo $WG_SERVER_PRIVATE | wg pubkey)
WG_CLIENT_PRIVATE=$(wg genkey)
WG_CLIENT_PUBLIC=$(echo $WG_CLIENT_PRIVATE | wg pubkey)

# WireGuard server config
sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOF
[Interface]
PrivateKey = $WG_SERVER_PRIVATE
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = $WG_CLIENT_PUBLIC
AllowedIPs = 10.0.0.2/32
EOF

# WireGuard client config
cat > wireguard-client.conf <<EOF
[Interface]
PrivateKey = $WG_CLIENT_PRIVATE
Address = 10.0.0.2/24
DNS = 8.8.8.8

[Peer]
PublicKey = $WG_SERVER_PUBLIC
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

# Add tunnel name to config
sed -i '1i# Name = SuperShadowVPN' wireguard-client.conf

# === OpenVPN Setup ===
echo "Setting up OpenVPN..."

# Create OpenVPN directory
mkdir -p ~/openvpn-ca
cd ~/openvpn-ca

# Initialize PKI
/usr/share/easy-rsa/easyrsa init-pki
echo "SuperShadowVPN" | /usr/share/easy-rsa/easyrsa build-ca nopass
/usr/share/easy-rsa/easyrsa gen-req server nopass
echo "yes" | /usr/share/easy-rsa/easyrsa sign-req server server
/usr/share/easy-rsa/easyrsa gen-dh
openvpn --genkey secret ta.key

# Generate client cert
/usr/share/easy-rsa/easyrsa gen-req client nopass
echo "yes" | /usr/share/easy-rsa/easyrsa sign-req client client

# Copy to OpenVPN directory
sudo cp pki/ca.crt /etc/openvpn/
sudo cp pki/issued/server.crt /etc/openvpn/
sudo cp pki/private/server.key /etc/openvpn/
sudo cp pki/dh.pem /etc/openvpn/
sudo cp ta.key /etc/openvpn/

# OpenVPN server config
sudo tee /etc/openvpn/server.conf > /dev/null <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
cipher AES-256-CBC
persist-key
persist-tun
verb 3
EOF

# OpenVPN client config
cd /workspaces/SuperShadowVPN
cat > openvpn-client.ovpn <<EOF
client
dev tun
proto udp
remote $SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
cipher AES-256-CBC
verb 3
<ca>
$(cat ~/openvpn-ca/pki/ca.crt)
</ca>
<cert>
$(cat ~/openvpn-ca/pki/issued/client.crt)
</cert>
<key>
$(cat ~/openvpn-ca/pki/private/client.key)
</key>
<tls-auth>
$(cat ~/openvpn-ca/ta.key)
</tls-auth>
key-direction 1
EOF

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configure firewall
sudo iptables -A INPUT -p udp --dport 51820 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 1194 -j ACCEPT
sudo iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

# Start services
sudo wg-quick up wg0
sudo systemctl start openvpn@server

echo ""
echo "🚀 Both VPN servers are running!"
echo ""
echo "📱 WireGuard Setup:"
echo "Scan this QR code in WireGuard app:"
echo "Tunnel name will be: SuperShadowVPN"
qrencode -t ansiutf8 < wireguard-client.conf
echo ""
echo "📱 OpenVPN Setup:"
echo "Import this file: openvpn-client.ovpn"
echo ""
echo "✅ Files created:"
echo "- wireguard-client.conf"
echo "- openvpn-client.ovpn"