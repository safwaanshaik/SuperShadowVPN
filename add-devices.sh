#!/bin/bash

echo "SuperShadowVPN - Add Multiple Devices"
echo "===================================="

# Check current peers
CURRENT_PEERS=$(sudo wg show wg0 peers | wc -l)
echo "Currently connected devices: $CURRENT_PEERS"

read -p "How many additional devices to add? " NUM_DEVICES

if [ "$NUM_DEVICES" -lt 1 ]; then
    echo "Invalid number"
    exit 1
fi

SERVER_IP=$(curl -s ifconfig.me)

for i in $(seq 1 $NUM_DEVICES); do
    DEVICE_NUM=$((CURRENT_PEERS + i + 1))
    
    # Generate keys for new device
    CLIENT_PRIVATE=$(wg genkey)
    CLIENT_PUBLIC=$(echo $CLIENT_PRIVATE | wg pubkey)
    
    # Add peer to server
    sudo wg set wg0 peer $CLIENT_PUBLIC allowed-ips 10.0.0.$DEVICE_NUM/32
    
    # Create client config
    cat > device-$DEVICE_NUM.conf <<EOF
# Name = SuperShadowVPN-Device$DEVICE_NUM
[Interface]
PrivateKey = $CLIENT_PRIVATE
Address = 10.0.0.$DEVICE_NUM/24
DNS = 8.8.8.8

[Peer]
PublicKey = $(sudo wg show wg0 public-key)
Endpoint = $SERVER_IP:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF
    
    echo "✅ Created: device-$DEVICE_NUM.conf"
done

# Update server config permanently
sudo wg-quick save wg0

echo ""
echo "🚀 Added $NUM_DEVICES new device slots"
echo "📱 QR codes for new devices:"
echo ""

for i in $(seq 1 $NUM_DEVICES); do
    DEVICE_NUM=$((CURRENT_PEERS + i + 1))
    echo "Device $DEVICE_NUM:"
    qrencode -t ansiutf8 < device-$DEVICE_NUM.conf
    echo ""
done

echo "Total capacity: Up to 253 devices (10.0.0.2 - 10.0.0.254)"