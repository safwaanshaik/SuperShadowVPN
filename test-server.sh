#!/bin/bash

echo "Starting SuperShadowVPN test server..."

# Build server if not exists
if [ ! -f "build/supershadowvpn-server" ]; then
    echo "Building server..."
    make server
fi

# Get public IP for iPhone connection
PUBLIC_IP=$(curl -s ifconfig.me)
echo "Server will be accessible at: $PUBLIC_IP:8080"
echo "Use this address in your iPhone app"

# Start server
./build/supershadowvpn-server