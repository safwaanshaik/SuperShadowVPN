#!/bin/bash

echo "SuperShadowVPN - Railway FREE Deployment"
echo "========================================"

# Railway.app FREE deployment
cat > railway-start.sh <<'EOF'
#!/bin/bash
# Railway.app - $5 credit monthly (effectively free)

# Install WireGuard
apt-get update
apt-get install -y wireguard qrencode curl

# Generate keys
SERVER_PRIVATE=$(wg genkey)
SERVER_PUBLIC=$(echo $SERVER_PRIVATE | wg pubkey)
CLIENT_PRIVATE=$(wg genkey)
CLIENT_PUBLIC=$(echo $CLIENT_PRIVATE | wg pubkey)

# Get Railway domain
RAILWAY_DOMAIN=${RAILWAY_STATIC_URL:-"localhost"}

# Configure WireGuard
tee /etc/wireguard/wg0.conf > /dev/null <<EOL
[Interface]
PrivateKey = $SERVER_PRIVATE
Address = 10.0.0.1/24
ListenPort = 51820
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

[Peer]
PublicKey = $CLIENT_PUBLIC
AllowedIPs = 10.0.0.2/32
EOL

# Client config
cat > client.conf <<EOL
# Name = SuperShadowVPN-Railway
[Interface]
PrivateKey = $CLIENT_PRIVATE
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC
Endpoint = $RAILWAY_DOMAIN:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOL

# Start VPN
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

echo "✅ Railway VPN Active!"
qrencode -t ansiutf8 < client.conf
EOF

# Create Dockerfile for Railway
cat > Dockerfile <<'EOF'
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    wireguard \
    qrencode \
    curl \
    iptables

COPY railway-start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 51820/udp

CMD ["/start.sh"]
EOF

echo ""
echo "🚂 Railway.app Deployment:"
echo "1. Push to GitHub"
echo "2. Connect Railway to your repo"
echo "3. Deploy automatically"
echo "4. Get FREE VPN server!"
echo ""
echo "💰 Cost: FREE ($5 credit monthly)"