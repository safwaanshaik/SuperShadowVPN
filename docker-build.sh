#!/bin/bash

echo "🐳 Building SuperShadowVPN Docker Image"
echo "======================================="

# Build the Docker image
echo "Building supershadowvpn image..."
docker build -t supershadowvpn .

echo ""
echo "✅ Build complete!"
echo ""
echo "🚀 Quick start options:"
echo ""
echo "1. Run with Docker:"
echo "   docker run -d --name vpn-server --privileged --net=host supershadowvpn"
echo ""
echo "2. Run with Docker Compose:"
echo "   docker-compose up -d"
echo ""
echo "3. Get client configs:"
echo "   docker exec vpn-server cat /root/clients/client1-wg.conf"
echo "   docker exec vpn-server qrencode -t ansiutf8 < /root/clients/client1-wg.conf"
echo ""
echo "4. View logs:"
echo "   docker logs vpn-server"
echo ""
echo "🛡️ SuperShadowVPN Docker image ready for deployment!"