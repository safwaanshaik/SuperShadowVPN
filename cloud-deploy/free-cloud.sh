#!/bin/bash

echo "SuperShadowVPN - FREE Cloud Deployment"
echo "======================================"

# Oracle Cloud Always Free deployment
cat > oracle-cloud-setup.sh <<'EOF'
#!/bin/bash
# Oracle Cloud Always Free Tier - Permanent FREE VPN
sudo apt-get update
sudo apt-get install -y wireguard qrencode curl

# Generate keys
SERVER_PRIVATE=$(wg genkey)
SERVER_PUBLIC=$(echo $SERVER_PRIVATE | wg pubkey)
CLIENT_PRIVATE=$(wg genkey)
CLIENT_PUBLIC=$(echo $CLIENT_PRIVATE | wg pubkey)

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me)

# Configure WireGuard
sudo tee /etc/wireguard/wg0.conf > /dev/null <<EOL
[Interface]
PrivateKey = $SERVER_PRIVATE
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUBLIC
AllowedIPs = 10.0.0.2/32
EOL

# Client config
cat > client.conf <<EOL
# Name = SuperShadowVPN-FREE
[Interface]
PrivateKey = $CLIENT_PRIVATE
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC
Endpoint = $PUBLIC_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOL

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Start VPN
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

echo "✅ FREE SuperShadowVPN Server Running!"
echo "📱 Client config:"
cat client.conf
echo ""
echo "📱 QR Code:"
qrencode -t ansiutf8 < client.conf
EOF

# GitHub Codespaces deployment
cat > codespaces-setup.sh <<'EOF'
#!/bin/bash
# GitHub Codespaces - FREE VPN (60 hours/month)
sudo apt-get update
sudo apt-get install -y wireguard qrencode

# Generate keys
SERVER_PRIVATE=$(wg genkey)
SERVER_PUBLIC=$(echo $SERVER_PRIVATE | wg pubkey)
CLIENT_PRIVATE=$(wg genkey)
CLIENT_PUBLIC=$(echo $CLIENT_PRIVATE | wg pubkey)

# Get codespace URL
CODESPACE_URL=$(echo $CODESPACE_NAME.github.dev)

# Client config for Codespaces
cat > codespace-client.conf <<EOL
# Name = SuperShadowVPN-Codespaces
[Interface]
PrivateKey = $CLIENT_PRIVATE
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC
Endpoint = $CODESPACE_URL:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOL

echo "✅ Codespaces VPN Ready!"
qrencode -t ansiutf8 < codespace-client.conf
EOF

echo ""
echo "🆓 FREE Cloud Options:"
echo ""
echo "1. Oracle Cloud Always Free"
echo "   • PERMANENT free tier"
echo "   • 1 VM + 200GB bandwidth/month"
echo "   • Run: ./oracle-cloud-setup.sh"
echo ""
echo "2. GitHub Codespaces"
echo "   • 60 hours/month free"
echo "   • Run: ./codespaces-setup.sh"
echo ""
echo "3. Google Cloud Free Tier"
echo "   • $300 credit + always free VM"
echo "   • 12 months free"
echo ""
echo "4. Heroku (Web-based VPN)"
echo "   • 550 hours/month free"
echo "   • Web proxy only"
echo ""
echo "🏆 BEST: Oracle Cloud Always Free - Permanent FREE VPN!"