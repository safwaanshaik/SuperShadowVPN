#!/bin/bash

echo "SuperShadowVPN - Local Network Discovery"
echo "======================================="

# Scan for nearby SuperShadowVPN servers
echo "🔍 Scanning local network for VPN nodes..."

# Get local network range
LOCAL_NET=$(ip route | grep -E "192\.168\.|10\.|172\." | head -1 | awk '{print $1}')
echo "Scanning network: $LOCAL_NET"

# Scan for WireGuard ports
nmap -sU -p 51820 $LOCAL_NET --open 2>/dev/null | grep -B2 "51820/udp open"

# Scan for common VPN ports
echo ""
echo "🔎 Scanning for other VPN services..."
nmap -sT -p 1194,1723,4500,500 $LOCAL_NET --open 2>/dev/null

# Check for SuperShadowVPN broadcast
echo ""
echo "📡 Listening for SuperShadowVPN broadcasts..."
timeout 5 nc -ul 9999 | grep "SuperShadowVPN" || echo "No broadcasts detected"

echo ""
echo "✅ Network scan complete"
echo "💡 Found VPN servers can be added as mesh peers"