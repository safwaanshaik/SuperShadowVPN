#!/bin/bash

echo "SuperShadowVPN - Send configs to your phone"
echo ""

# Check if config files exist
if [ ! -f "wireguard-client.conf" ]; then
    echo "❌ WireGuard config not found. Run ./start-vpn-servers.sh first"
    exit 1
fi

if [ ! -f "openvpn-client.ovpn" ]; then
    echo "❌ OpenVPN config not found. Run ./start-vpn-servers.sh first"
    exit 1
fi

echo "📱 How to get configs to your phone:"
echo ""
echo "Option 1 - QR Code (WireGuard only):"
echo "Scan this with WireGuard app:"
qrencode -t ansiutf8 < wireguard-client.conf
echo ""
echo "Option 2 - Email yourself:"
echo "Email these files to yourself:"
echo "- wireguard-client.conf"
echo "- openvpn-client.ovpn"
echo ""
echo "Option 3 - Cloud storage:"
echo "Upload to Google Drive/iCloud and download on phone"
echo ""
echo "Option 4 - HTTP server:"
read -p "Start local HTTP server to download configs? (y/n): " start_server

if [ "$start_server" = "y" ]; then
    SERVER_IP=$(curl -s ifconfig.me)
    echo ""
    echo "🌐 Starting HTTP server..."
    echo "Download configs from your phone at:"
    echo "http://$SERVER_IP:8000/wireguard-client.conf"
    echo "http://$SERVER_IP:8000/openvpn-client.ovpn"
    echo ""
    echo "Press Ctrl+C to stop server"
    python3 -m http.server 8000
fi