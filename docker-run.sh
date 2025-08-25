#!/bin/bash

echo "🐳 SuperShadowVPN Docker Quick Start"
echo "===================================="

# Build image
echo "Building image..."
docker build -t supershadowvpn .

# Run container
echo "Starting container..."
docker run -d \
  --name supershadowvpn \
  --privileged \
  --net=host \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  -v $(pwd)/configs:/root/clients \
  supershadowvpn

echo ""
echo "✅ Container started!"
echo ""
echo "📱 Get QR code:"
echo "docker logs supershadowvpn"
echo ""
echo "📄 Get config files:"
echo "ls -la configs/"
echo ""
echo "🔧 Container management:"
echo "docker stop supershadowvpn"
echo "docker start supershadowvpn"
echo "docker rm supershadowvpn"