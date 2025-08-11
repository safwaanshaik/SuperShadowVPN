#!/bin/bash

echo "SuperShadowVPN Auto-Restart Setup"
echo "================================="

# Create systemd service for auto-start
sudo tee /etc/systemd/system/supershadowvpn.service > /dev/null <<EOF
[Unit]
Description=SuperShadowVPN Military-Grade Server
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/bash -c 'cd /workspaces/SuperShadowVPN && wg-quick up wg0'
ExecStop=/bin/bash -c 'wg-quick down wg0'
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable auto-start on boot
sudo systemctl enable supershadowvpn
sudo systemctl daemon-reload

# Create backup script
cat > backup-config.sh <<EOF
#!/bin/bash
# Backup all VPN configs
mkdir -p ~/supershadowvpn-backup
cp -r /workspaces/SuperShadowVPN/* ~/supershadowvpn-backup/
cp /etc/wireguard/wg0.conf ~/supershadowvpn-backup/ 2>/dev/null || true
echo "✅ Backup saved to ~/supershadowvpn-backup"
EOF

chmod +x backup-config.sh
./backup-config.sh

echo ""
echo "🔄 Auto-restart configured!"
echo "✅ VPN will start automatically on laptop boot"
echo "💾 Configs backed up to ~/supershadowvpn-backup"
echo ""
echo "Your phone will reconnect automatically when laptop restarts!"