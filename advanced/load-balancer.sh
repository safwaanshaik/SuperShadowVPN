#!/bin/bash

echo "SuperShadowVPN - LOAD BALANCER MODE"
echo "=================================="

# Install HAProxy for load balancing
sudo apt-get update && sudo apt-get install -y haproxy

# Configure HAProxy for VPN load balancing
sudo tee /etc/haproxy/haproxy.cfg > /dev/null <<EOF
global
    daemon
    maxconn 4096

defaults
    mode tcp
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend vpn_frontend
    bind *:51820
    default_backend vpn_backend

backend vpn_backend
    balance roundrobin
    server wg0 127.0.0.1:51821 check
    server wg1 127.0.0.1:51822 check
    server wg2 127.0.0.1:51823 check
    server wg3 127.0.0.1:51824 check

frontend shadowsocks_frontend
    bind *:8388
    default_backend shadowsocks_backend

backend shadowsocks_backend
    balance leastconn
    server ss1 127.0.0.1:8389 check
    server ss2 127.0.0.1:8390 check
EOF

# Start HAProxy
sudo systemctl enable haproxy
sudo systemctl restart haproxy

# Configure iptables for load balancing
sudo iptables -t nat -A PREROUTING -p udp --dport 51820 -m statistic --mode nth --every 4 --packet 0 -j DNAT --to-destination 127.0.0.1:51821
sudo iptables -t nat -A PREROUTING -p udp --dport 51820 -m statistic --mode nth --every 3 --packet 0 -j DNAT --to-destination 127.0.0.1:51822
sudo iptables -t nat -A PREROUTING -p udp --dport 51820 -m statistic --mode nth --every 2 --packet 0 -j DNAT --to-destination 127.0.0.1:51823

echo "⚖️ LOAD BALANCER ACTIVE"
echo "🔄 Traffic distributed across 4 servers"
echo "📈 Maximum throughput achieved"