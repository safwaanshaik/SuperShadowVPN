#!/usr/bin/env bash

# SuperShadowVPN one-shot setup for Ubuntu 24.04+ (OpenVPN + WireGuard)

# Configuration variables
CLIENT_COUNT=1
DNS_SERVERS="1.1.1.1,1.0.0.1"
WG_PORT=51820
OVPN_PORT=1194
OVPN_PROTO="udp"
SERVER_NAME="server"
ORG_NAME="SuperShadowVPN"
COUNTRY="US"
STATE="CA"
LOCALITY="SF"
ORG_UNIT="IT"
EMAIL="admin@example.com"
EASYRSA_DIR="/etc/openvpn/easy-rsa"
OVPN_DIR="/etc/openvpn"
OVPN_SERVER_DIR="/etc/openvpn/server"
CLIENTS_DIR="/root/clients"
WG_CONF="/etc/wireguard/wg0.conf"
WG_NET_IPV4="10.8.0.0/24"
WG_SRV_IPV4="10.8.0.1/24"
WG_NET_IPV6="fd86:ea04:1115::/64"
WG_SRV_IPV6="fd86:ea04:1115::1/64"
IPV6_ENABLE=1

# Install packages
apt-get update -y
apt-get install -y --no-install-recommends openvpn easy-rsa wireguard qrencode curl iproute2 ca-certificates

# Enable IP forwarding
sed -i 's|^#\?net.ipv4.ip_forward=.*|net.ipv4.ip_forward=1|' /etc/sysctl.conf
sysctl -w net.ipv4.ip_forward=1 >/dev/null
if [[ "${IPV6_ENABLE}" == "1" ]]; then
  sed -i 's|^#\?net.ipv6.conf.all.forwarding=.*|net.ipv6.conf.all.forwarding=1|' /etc/sysctl.conf
  sysctl -w net.ipv6.conf.all.forwarding=1 >/dev/null || true
fi

# Configure OpenVPN
mkdir -p "${OVPN_SERVER_DIR}"
cp -r /usr/share/easy-rsa "${EASYRSA_DIR}"
cd "${EASYRSA_DIR}"

cat > "${EASYRSA_DIR}/vars" <<EOF
set_var EASYRSA_REQ_COUNTRY     "${COUNTRY}"
set_var EASYRSA_REQ_PROVINCE    "${STATE}"
set_var EASYRSA_REQ_CITY        "${LOCALITY}"
set_var EASYRSA_REQ_ORG         "${ORG_NAME}"
set_var EASYRSA_REQ_EMAIL       "${EMAIL}"
set_var EASYRSA_REQ_OU          "${ORG_UNIT}"
set_var EASYRSA_BATCH           "1"
EOF

./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa gen-req "${SERVER_NAME}" nopass
./easyrsa sign-req server "${SERVER_NAME}" <<< "yes"
./easyrsa gen-dh
openvpn --genkey secret "${EASYRSA_DIR}/pki/ta.key"

cp -f "${EASYRSA_DIR}/pki/ca.crt" "${OVPN_SERVER_DIR}/"
cp -f "${EASYRSA_DIR}/pki/issued/${SERVER_NAME}.crt" "${OVPN_SERVER_DIR}/server.crt"
cp -f "${EASYRSA_DIR}/pki/private/${SERVER_NAME}.key" "${OVPN_SERVER_DIR}/server.key"
cp -f "${EASYRSA_DIR}/pki/dh.pem" "${OVPN_SERVER_DIR}/dh.pem"
cp -f "${EASYRSA_DIR}/pki/ta.key" "${OVPN_SERVER_DIR}/ta.key"

PUBLIC_IP="$(curl -4s https://ifconfig.me || curl -4s https://ipinfo.io/ip || ip -4 route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}' || echo "127.0.0.1")"
DNS_LINE=""
IFS=',' read -ra DNS_ARR <<< "${DNS_SERVERS}"
for d in "${DNS_ARR[@]}"; do
  DNS_LINE+="push \"dhcp-option DNS ${d}\"\n"
done

if [[ "${IPV6_ENABLE}" == "1" ]]; then
  OVPN_SERVER_DIRECTIVES_IPV6=$'server-ipv6 fd42:42:42::/112\npush "redirect-gateway ipv6"\n'
else
  OVPN_SERVER_DIRECTIVES_IPV6=""
fi

cat > "${OVPN_SERVER_DIR}/server.conf" <<EOF
port ${OVPN_PORT}
proto ${OVPN_PROTO}
dev tun
user nobody
group nogroup
ca ${OVPN_SERVER_DIR}/ca.crt
cert ${OVPN_SERVER_DIR}/server.crt
key ${OVPN_SERVER_DIR}/server.key
dh ${OVPN_SERVER_DIR}/dh.pem
tls-crypt ${OVPN_SERVER_DIR}/ta.key
topology subnet
server 10.9.0.0 255.255.255.0
${OVPN_SERVER_DIRECTIVES_IPV6}push "redirect-gateway def1 bypass-dhcp"
$(echo -e "${DNS_LINE}")keepalive 10 120
persist-key
persist-tun
status /var/log/openvpn-status.log
log-append /var/log/openvpn.log
verb 3
explicit-exit-notify 1
EOF

DEFAULT_IF="$(ip -4 route ls default | awk '{print $5; exit}')"
mkdir -p /etc/systemd/system
cat > /etc/systemd/system/openvpn-nat.service <<EOF
[Unit]
Description=OpenVPN NAT rules
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c 'iptables -t nat -C POSTROUTING -s 10.9.0.0/24 -o ${DEFAULT_IF} -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o ${DEFAULT_IF} -j MASQUERADE'
ExecStop=/bin/sh -c 'iptables -t nat -D POSTROUTING -s 10.9.0.0/24 -o ${DEFAULT_IF} -j MASQUERADE 2>/dev/null || true'

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now openvpn-nat.service

# Generate OpenVPN clients
mkdir -p "${CLIENTS_DIR}"
generate_ovpn_client() {
  local name="$1"
  cd "${EASYRSA_DIR}"
  ./easyrsa gen-req "${name}" nopass
  ./easyrsa sign-req client "${name}" <<< "yes"

  local CLIENT_CONF="${CLIENTS_DIR}/${name}.ovpn"
  cat > "${CLIENT_CONF}" <<EOF
client
dev tun
proto ${OVPN_PROTO}
remote ${PUBLIC_IP} ${OVPN_PORT}
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
key-direction 1
verb 3

<ca>
$(cat "${EASYRSA_DIR}/pki/ca.crt")
</ca>
<cert>
$(awk '/BEGIN/,/END/' "${EASYRSA_DIR}/pki/issued/${name}.crt")
</cert>
<key>
$(cat "${EASYRSA_DIR}/pki/private/${name}.key")
</key>
<tls-crypt>
$(cat "${EASYRSA_DIR}/pki/ta.key")
</tls-crypt>
EOF
  echo "[+] Wrote ${CLIENT_CONF}"
}

i=1
while [[ $i -le ${CLIENT_COUNT} ]]; do
  generate_ovpn_client "client${i}"
  ((i++))
done

# Start OpenVPN server
systemctl enable --now openvpn-server@server.service
sleep 1
systemctl --no-pager -l status openvpn-server@server.service || true

# Configure WireGuard
mkdir -p /etc/wireguard
umask 077
wg genkey | tee /etc/wireguard/server_private.key | wg pubkey > /etc/wireguard/server_public.key
WG_PRIV="$(cat /etc/wireguard/server_private.key)"

DNS_PRIMARY="$(echo "${DNS_SERVERS}" | cut -d',' -f1)"

cat > "${WG_CONF}" <<EOF
[Interface]
Address = ${WG_SRV_IPV4}$( [[ "${IPV6_ENABLE}" == "1" ]] && echo ", ${WG_SRV_IPV6}" )
ListenPort = ${WG_PORT}
PrivateKey = ${WG_PRIV}
PostUp = sysctl -w net.ipv4.ip_forward=1 >/dev/null
PostUp = iptables -C FORWARD -i %i -j ACCEPT 2>/dev/null || iptables -A FORWARD -i %i -j ACCEPT
PostUp = iptables -C FORWARD -o %i -j ACCEPT 2>/dev/null || iptables -A FORWARD -o %i -j ACCEPT
PostUp = iptables -t nat -C POSTROUTING -s ${WG_NET_IPV4} -o ${DEFAULT_IF} -j MASQUERADE 2>/dev/null || iptables -t nat -A POSTROUTING -s ${WG_NET_IPV4} -o ${DEFAULT_IF} -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT 2>/dev/null || true
PostDown = iptables -D FORWARD -o %i -j ACCEPT 2>/dev/null || true
PostDown = iptables -t nat -D POSTROUTING -s ${WG_NET_IPV4} -o ${DEFAULT_IF} -j MASQUERADE 2>/dev/null || true
SaveConfig = false
EOF

chmod 600 "${WG_CONF}"

# Generate WireGuard clients
generate_wg_client() {
  local name="$1"
  local last_octet="$2"
  umask 077
  local c_priv c_pub c_psk
  c_priv="$(wg genkey)"
  c_pub="$(echo "${c_priv}" | wg pubkey)"
  c_psk="$(wg genpsk)"
  local srv_pub
  srv_pub="$(cat /etc/wireguard/server_public.key)"

  local base_ipv4="10.8.0."
  local client_ipv4="${base_ipv4}${last_octet}/32"

  local client_ipv6=""
  if [[ "${IPV6_ENABLE}" == "1" ]]; then
    client_ipv6="fd86:ea04:1115::${last_octet}/128"
  fi

  cat >> "${WG_CONF}" <<EOF

# ${name}
[Peer]
PublicKey = ${c_pub}
PresharedKey = ${c_psk}
AllowedIPs = ${client_ipv4}$( [[ "${IPV6_ENABLE}" == "1" ]] && echo ", ${client_ipv6}" )
EOF

  local CLIENT_WG="${CLIENTS_DIR}/${name}-wg.conf"
  cat > "${CLIENT_WG}" <<EOF
[Interface]
PrivateKey = ${c_priv}
Address = ${client_ipv4}$( [[ "${IPV6_ENABLE}" == "1" ]] && echo ", ${client_ipv6}" )
DNS = ${DNS_PRIMARY}

[Peer]
PublicKey = ${srv_pub}
PresharedKey = ${c_psk}
Endpoint = ${PUBLIC_IP}:${WG_PORT}
AllowedIPs = 0.0.0.0/0$( [[ "${IPV6_ENABLE}" == "1" ]] && echo ", ::/0" )
PersistentKeepalive = 25
EOF

  echo "[+] Wrote ${CLIENT_WG}"
  echo "[*] QR code for ${name}:"
  qrencode -t ansiutf8 < "${CLIENT_WG}" || true
}

i=1
while [[ $i -le ${CLIENT_COUNT} ]]; do
  oct=$((10 + i))
  generate_wg_client "client${i}" "${oct}"
  ((i++))
done

# Start WireGuard
systemctl enable --now wg-quick@wg0.service
sleep 1
systemctl --no-pager -l status wg-quick@wg0.service || true

echo
echo "==============================================================="
echo " SuperShadowVPN is ready"
echo " Public IP: ${PUBLIC_IP}"
echo " OpenVPN: ${OVPN_PROTO}://${PUBLIC_IP}:${OVPN_PORT}"
echo " WireGuard: ${PUBLIC_IP}:${WG_PORT}"
echo " Client files in: ${CLIENTS_DIR}"
echo "  - OpenVPN: clientN.ovpn"
echo "  - WireGuard: clientN-wg.conf (QR printed above)"
echo "==============================================================="