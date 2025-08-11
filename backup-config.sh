#!/bin/bash
# Backup all VPN configs
mkdir -p ~/supershadowvpn-backup
cp -r /workspaces/SuperShadowVPN/* ~/supershadowvpn-backup/
cp /etc/wireguard/wg0.conf ~/supershadowvpn-backup/ 2>/dev/null || true
echo "✅ Backup saved to ~/supershadowvpn-backup"
