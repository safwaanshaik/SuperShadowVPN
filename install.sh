#!/bin/bash

echo "Installing SuperShadowVPN..."

# Check Go installation
if ! command -v go &> /dev/null; then
    echo "Go is not installed. Please install Go 1.21 or later."
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
go mod tidy
go mod download

# Build binaries
echo "Building SuperShadowVPN..."
make build

# Create config directory
mkdir -p ~/.supershadowvpn
cp config/config.json ~/.supershadowvpn/

# Set permissions
chmod +x build/supershadowvpn-server
chmod +x build/supershadowvpn-client

echo "SuperShadowVPN installed successfully!"
echo "Server binary: ./build/supershadowvpn-server"
echo "Client binary: ./build/supershadowvpn-client"
echo "Config file: ~/.supershadowvpn/config.json"