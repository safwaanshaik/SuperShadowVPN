#!/bin/bash

# Install L2TP/IPSec VPN server for mobile devices
echo "Setting up L2TP/IPSec VPN server for mobile..."

# Install required packages
sudo apt-get update
sudo apt-get install -y strongswan xl2tpd ppp-dev

# Get server IP
SERVER_IP=$(curl -s ifconfig.me)
LOCAL_IP=$(hostname -I | awk '{print $1}')

echo "Server IP: $SERVER_IP"
echo "Local IP: $LOCAL_IP"

# Configure strongSwan (IPSec)
sudo tee /etc/ipsec.conf > /dev/null <<EOF
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn l2tp-psk
    auto=add
    keyexchange=ikev1
    authby=secret
    type=transport
    left=$LOCAL_IP
    leftprotoport=17/1701
    right=%any
    rightprotoport=17/%any
    dpddelay=40
    dpdtimeout=130
    dpdaction=clear
EOF

# Configure IPSec secrets
sudo tee /etc/ipsec.secrets > /dev/null <<EOF
: PSK "SuperShadowVPN2024"
EOF

# Configure xl2tpd
sudo tee /etc/xl2tpd/xl2tpd.conf > /dev/null <<EOF
[global]
port = 1701

[lns default]
ip range = 10.10.10.10-10.10.10.100
local ip = 10.10.10.1
require chap = yes
refuse pap = yes
require authentication = yes
name = l2tpd
ppp debug = yes
pppoptfile = /etc/ppp/options.xl2tpd
length bit = yes
EOF

# Configure PPP
sudo tee /etc/ppp/options.xl2tpd > /dev/null <<EOF
ipcp-accept-local
ipcp-accept-remote
ms-dns 8.8.8.8
ms-dns 8.8.4.4
noccp
auth
crtscts
idle 1800
mtu 1280
mru 1280
lock
connect-delay 5000
EOF

# Add VPN user
sudo tee /etc/ppp/chap-secrets > /dev/null <<EOF
vpnuser l2tpd vpnpass123 *
EOF

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configure firewall
sudo iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE
sudo iptables -A INPUT -p udp --dport 500 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 4500 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 1701 -j ACCEPT
sudo iptables -A FORWARD -s 10.10.10.0/24 -j ACCEPT
sudo iptables -A FORWARD -d 10.10.10.0/24 -j ACCEPT

# Start services
sudo systemctl enable strongswan
sudo systemctl enable xl2tpd
sudo systemctl start strongswan
sudo systemctl start xl2tpd

echo ""
echo "🚀 L2TP/IPSec VPN Server is ready!"
echo ""
echo "📱 Add VPN on your phone:"
echo "Type: L2TP/IPSec PSK"
echo "Server: $SERVER_IP"
echo "Username: vpnuser"
echo "Password: vpnpass123"
echo "Pre-shared Key: SuperShadowVPN2024"
echo ""
echo "✅ Your phone can now connect through VPN settings!"