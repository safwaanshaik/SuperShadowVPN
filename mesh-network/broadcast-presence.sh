#!/bin/bash

echo "SuperShadowVPN - Broadcasting Presence"
echo "====================================="

# Broadcast SuperShadowVPN presence to local network
SERVER_IP=$(hostname -I | awk '{print $1}')
SERVER_PUBLIC_KEY=$(sudo wg show wg0 public-key 2>/dev/null || echo "NO_KEY")

# Create broadcast message
BROADCAST_MSG="{
  \"service\": \"SuperShadowVPN\",
  \"version\": \"military-grade\",
  \"server_ip\": \"$SERVER_IP\",
  \"port\": 51820,
  \"public_key\": \"$SERVER_PUBLIC_KEY\",
  \"features\": [\"stealth\", \"quantum-resistant\", \"ai-protection\", \"zero-logs\"],
  \"timestamp\": $(date +%s)
}"

echo "📡 Broadcasting SuperShadowVPN presence..."
echo "Server: $SERVER_IP:51820"

# Broadcast on UDP port 9999
while true; do
    echo "$BROADCAST_MSG" | nc -u -b 255.255.255.255 9999
    sleep 30
done &

BROADCAST_PID=$!
echo "✅ Broadcasting started (PID: $BROADCAST_PID)"
echo "🔍 Other SuperShadowVPN nodes can now discover this server"
echo "⏹️  Stop with: kill $BROADCAST_PID"

# Keep script running
wait