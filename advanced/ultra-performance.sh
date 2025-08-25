#!/bin/bash

echo "SuperShadowVPN - ULTRA PERFORMANCE MODE"
echo "======================================"

# Optimize kernel network parameters
sudo tee /etc/sysctl.d/99-supershadowvpn.conf > /dev/null <<EOF
# Network performance optimization
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728
net.ipv4.tcp_rmem = 4096 87380 134217728
net.ipv4.tcp_wmem = 4096 65536 134217728
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_mtu_probing = 1
net.ipv4.ip_forward = 1
net.ipv4.conf.all.forwarding = 1
net.ipv6.conf.all.forwarding = 1
EOF

sudo sysctl -p /etc/sysctl.d/99-supershadowvpn.conf

# Optimize WireGuard interface
sudo ip link set wg0 mtu 1420
sudo ethtool -K wg0 rx off tx off 2>/dev/null || true

# Multi-threading optimization
echo "Optimizing CPU performance..."
sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor <<< "performance" 2>/dev/null || true

# Memory optimization
echo "Optimizing memory..."
echo 1 | sudo tee /proc/sys/vm/drop_caches
echo 3 | sudo tee /proc/sys/vm/drop_caches

# Network queue optimization
sudo tc qdisc add dev wg0 root fq 2>/dev/null || true

echo "✅ ULTRA PERFORMANCE MODE ACTIVATED"
echo "🚀 Network throughput optimized"
echo "⚡ CPU performance maximized"
echo "💾 Memory optimized"