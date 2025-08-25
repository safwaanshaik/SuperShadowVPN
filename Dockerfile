FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get update && apt-get install -y \
    openvpn \
    easy-rsa \
    wireguard \
    qrencode \
    curl \
    iproute2 \
    ca-certificates \
    iptables \
    && rm -rf /var/lib/apt/lists/*

# Copy setup script
COPY quick-setup.sh /setup.sh
RUN chmod +x /setup.sh

# Create directories
RUN mkdir -p /etc/openvpn/server /etc/wireguard /root/clients

# Expose ports
EXPOSE 1194/udp 51820/udp

# Startup script
RUN cat > /start.sh << 'EOF'
#!/bin/bash
echo 1 > /proc/sys/net/ipv4/ip_forward
echo 1 > /proc/sys/net/ipv6/conf/all/forwarding 2>/dev/null || true

if [ ! -f /etc/openvpn/server/server.conf ]; then
    /setup.sh
fi

PUBLIC_IP=$(curl -4s https://ifconfig.me 2>/dev/null || echo "localhost")
echo "SuperShadowVPN Ready - $PUBLIC_IP:51820"

if [ -f /root/clients/client1-wg.conf ]; then
    echo "WireGuard QR:"
    qrencode -t ansiutf8 < /root/clients/client1-wg.conf
fi

openvpn --daemon --config /etc/openvpn/server/server.conf 2>/dev/null || true
wg-quick up wg0 2>/dev/null || true

tail -f /dev/null
EOF

RUN chmod +x /start.sh

CMD ["/start.sh"]