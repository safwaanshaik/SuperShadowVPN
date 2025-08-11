#!/bin/bash

echo "Starting SuperShadowVPN for iPhone testing..."

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me)
echo "Your public IP: $PUBLIC_IP"

# Start web server
cd web
go mod tidy
go run server.go &
WEB_PID=$!

echo ""
echo "🚀 SuperShadowVPN is ready for iPhone testing!"
echo ""
echo "On your iPhone:"
echo "1. Open Safari"
echo "2. Go to: http://$PUBLIC_IP:8081"
echo "3. Tap 'Connect' to test VPN"
echo ""
echo "Press Ctrl+C to stop server"

# Wait for interrupt
trap "kill $WEB_PID" EXIT
wait