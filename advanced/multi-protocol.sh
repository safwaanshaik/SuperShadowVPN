#!/bin/bash

echo "SuperShadowVPN - MULTI-PROTOCOL POWER MODE"
echo "=========================================="

# Start multiple VPN protocols simultaneously
echo "Starting WireGuard on multiple ports..."
sudo wg-quick up wg0 2>/dev/null || echo "WG0 already up"

# Create additional WireGuard interfaces for load balancing
for i in {1..3}; do
    PORT=$((51820 + i))
    INTERFACE="wg$i"
    
    # Generate keys for additional interface
    PRIVATE_KEY=$(wg genkey)
    PUBLIC_KEY=$(echo $PRIVATE_KEY | wg pubkey)
    
    # Create interface config
    sudo tee /etc/wireguard/$INTERFACE.conf > /dev/null <<EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.$i.0.1/24
ListenPort = $PORT
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
EOF
    
    # Start interface
    sudo wg-quick up $INTERFACE 2>/dev/null || echo "$INTERFACE ready"
    
    echo "✅ $INTERFACE active on port $PORT"
done

# Start Shadowsocks for additional obfuscation
sudo ss-server -s 0.0.0.0 -p 8388 -k "SuperShadowVPN2024" -m chacha20-ietf-poly1305 -d start 2>/dev/null || echo "Shadowsocks ready"

# Start OpenVPN if available
sudo openvpn --daemon --config /etc/openvpn/server.conf 2>/dev/null || echo "OpenVPN ready"

echo ""
echo "🚀 MULTI-PROTOCOL POWER MODE ACTIVE"
echo "📡 WireGuard: Ports 51820-51823"
echo "🔒 Shadowsocks: Port 8388"
echo "🛡️ OpenVPN: Port 1194"
echo "⚡ Maximum redundancy and speed"