#!/bin/bash

echo "SuperShadowVPN Mobile Setup"
echo "=========================="
echo ""
echo "Choose VPN type for your mobile device:"
echo "1) L2TP/IPSec (Built-in iOS/Android support)"
echo "2) OpenVPN (Requires OpenVPN app)"
echo "3) WireGuard (Requires WireGuard app)"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo "Setting up L2TP/IPSec VPN..."
        chmod +x mobile-vpn/l2tp-server.sh
        ./mobile-vpn/l2tp-server.sh
        ;;
    2)
        echo "Setting up OpenVPN..."
        chmod +x mobile-vpn/openvpn-server.sh
        ./mobile-vpn/openvpn-server.sh
        ;;
    3)
        echo "Setting up WireGuard..."
        chmod +x mobile-vpn/wireguard-server.sh
        ./mobile-vpn/wireguard-server.sh
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac