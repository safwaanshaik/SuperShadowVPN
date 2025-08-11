#!/bin/bash

echo "Setting up OpenVPN server for mobile..."

# Install OpenVPN
sudo apt-get update
sudo apt-get install -y openvpn easy-rsa

# Setup CA
make-cadir ~/openvpn-ca
cd ~/openvpn-ca

# Generate server certificates
./easyrsa init-pki
echo "SuperShadowVPN" | ./easyrsa build-ca nopass
./easyrsa gen-req server nopass
./easyrsa sign-req server server
./easyrsa gen-dh
openvpn --genkey --secret ta.key

# Copy certificates
sudo cp pki/ca.crt /etc/openvpn/
sudo cp pki/issued/server.crt /etc/openvpn/
sudo cp pki/private/server.key /etc/openvpn/
sudo cp pki/dh.pem /etc/openvpn/
sudo cp ta.key /etc/openvpn/

# Create server config
sudo tee /etc/openvpn/server.conf > /dev/null <<EOF
port 1194
proto udp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh.pem
tls-auth ta.key 0
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
keepalive 10 120
cipher AES-256-CBC
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
verb 3
explicit-exit-notify 1
EOF

# Generate client config
./easyrsa gen-req client nopass
./easyrsa sign-req client client

# Create client config
SERVER_IP=$(curl -s ifconfig.me)
cat > ~/client.ovpn <<EOF
client
dev tun
proto udp
remote $SERVER_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
cipher AES-256-CBC
verb 3
<ca>
$(cat pki/ca.crt)
</ca>
<cert>
$(cat pki/issued/client.crt)
</cert>
<key>
$(cat pki/private/client.key)
</key>
<tls-auth>
$(cat ta.key)
</tls-auth>
key-direction 1
EOF

# Enable IP forwarding
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Configure firewall
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/8 -o eth0 -j MASQUERADE
sudo iptables -A INPUT -p udp --dport 1194 -j ACCEPT

# Start OpenVPN
sudo systemctl enable openvpn@server
sudo systemctl start openvpn@server

echo ""
echo "🚀 OpenVPN Server is ready!"
echo "📱 Client config saved to: ~/client.ovpn"
echo "📧 Send client.ovpn to your phone and import in OpenVPN app"