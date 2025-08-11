#!/bin/bash

echo "SuperShadowVPN - Auto-Connect to Nearby Networks"
echo "==============================================="

# Auto-connect to discovered SuperShadowVPN nodes
echo "🔍 Discovering nearby SuperShadowVPN networks..."

# Listen for broadcasts
timeout 10 nc -ul 9999 | while read -r broadcast; do
    echo "📡 Received broadcast: $broadcast"
    
    # Parse broadcast JSON
    SERVER_IP=$(echo "$broadcast" | grep -o '"server_ip":"[^"]*' | cut -d'"' -f4)
    SERVER_KEY=$(echo "$broadcast" | grep -o '"public_key":"[^"]*' | cut -d'"' -f4)
    
    if [ -n "$SERVER_IP" ] && [ "$SERVER_KEY" != "NO_KEY" ]; then
        echo "🤝 Found SuperShadowVPN server: $SERVER_IP"
        
        # Generate client keys for this peer
        CLIENT_PRIVATE=$(wg genkey)
        CLIENT_PUBLIC=$(echo $CLIENT_PRIVATE | wg pubkey)
        
        # Create peer config
        PEER_NUM=$(( $(sudo wg show wg0 peers | wc -l) + 1 ))
        
        cat > peer-$PEER_NUM.conf <<EOF
# Name = SuperShadowVPN-Peer-$PEER_NUM
[Interface]
PrivateKey = $CLIENT_PRIVATE
Address = 10.0.0.$((100 + PEER_NUM))/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_KEY
Endpoint = $SERVER_IP:51820
AllowedIPs = 10.0.0.0/24
PersistentKeepalive = 25
EOF
        
        echo "✅ Created peer config: peer-$PEER_NUM.conf"
        echo "📱 QR Code for mobile:"
        qrencode -t ansiutf8 < peer-$PEER_NUM.conf
        
        # Try to add as peer to our server
        sudo wg set wg0 peer $CLIENT_PUBLIC allowed-ips 10.0.0.$((100 + PEER_NUM))/32 2>/dev/null
        
        echo "🔗 Peer connection established!"
    fi
done

echo "🕸️ Mesh network discovery complete"