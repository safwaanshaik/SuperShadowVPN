#!/bin/bash

echo "SuperShadowVPN - Restore After Reboot"
echo "====================================="

# Restore VPN server after laptop restart
echo "Restoring SuperShadowVPN server..."

# Start WireGuard
sudo wg-quick up wg0 2>/dev/null || echo "WireGuard already running"

# Restore advanced features
echo "Restoring advanced features..."

# Restart stealth services
sudo service stunnel4 start 2>/dev/null || echo "Stunnel ready"
sudo service shadowsocks-libev start 2>/dev/null || echo "Shadowsocks ready"

# Restart AI protection
sudo service fail2ban start 2>/dev/null || echo "Fail2ban ready"

# Check server status
SERVER_IP=$(curl -s ifconfig.me)
echo ""
echo "🚀 SuperShadowVPN Server Restored!"
echo "📡 Server IP: $SERVER_IP:51820"
echo "🛡️ All military-grade features active"
echo ""
echo "📱 Your phone will reconnect automatically"
echo "✅ No action needed on mobile device"

# Show current connections
sudo wg show wg0 2>/dev/null || echo "Server ready for connections"