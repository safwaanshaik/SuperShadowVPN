#!/bin/bash

echo "SuperShadowVPN - Connected Devices"
echo "=================================="

# Show WireGuard status
sudo wg show wg0

echo ""
echo "Device capacity:"
echo "• Current setup: Up to 253 devices"
echo "• IP range: 10.0.0.2 - 10.0.0.254"
echo "• Theoretical limit: 65,000+ devices"
echo ""
echo "Performance limits:"
echo "• Laptop CPU/RAM: ~50-100 devices"
echo "• Network bandwidth: Depends on usage"
echo "• Recommended: 10-20 devices for best performance"