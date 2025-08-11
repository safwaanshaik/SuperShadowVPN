#!/bin/bash

echo "SuperShadowVPN - AWS Cloud Deployment"
echo "====================================="

# AWS EC2 deployment script
cat > aws-userdata.sh <<'EOF'
#!/bin/bash
apt-get update
apt-get install -y wireguard qrencode curl

# Generate keys
SERVER_PRIVATE=$(wg genkey)
SERVER_PUBLIC=$(echo $SERVER_PRIVATE | wg pubkey)
CLIENT_PRIVATE=$(wg genkey)
CLIENT_PUBLIC=$(echo $CLIENT_PRIVATE | wg pubkey)

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me)

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
cat > /home/ubuntu/client.conf <<EOL
# Name = SuperShadowVPN-Cloud
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
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# Start VPN
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

# Generate QR code
qrencode -t ansiutf8 < /home/ubuntu/client.conf > /home/ubuntu/qr.txt
EOF

echo "📋 AWS Deployment Instructions:"
echo ""
echo "1. Launch EC2 instance (Ubuntu 22.04)"
echo "2. Security Group: Allow UDP 51820"
echo "3. Use aws-userdata.sh as User Data"
echo "4. SSH to server and get client config:"
echo "   cat /home/ubuntu/client.conf"
echo "   cat /home/ubuntu/qr.txt"
echo ""
echo "💰 Cost: ~$5-10/month for t3.micro"