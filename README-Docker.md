# SuperShadowVPN Docker Deployment

🐳 **Containerized VPN Server with OpenVPN + WireGuard**

## Quick Start

### Option 1: Docker Build & Run
```bash
# Build the image
./docker-build.sh

# Run the container
docker run -d \
  --name supershadowvpn \
  --privileged \
  --net=host \
  --cap-add=NET_ADMIN \
  --device=/dev/net/tun \
  supershadowvpn
```

### Option 2: Docker Compose (Recommended)
```bash
# Start the VPN server
docker-compose up -d

# View logs
docker-compose logs -f
```

## Get Client Configurations

### WireGuard QR Code
```bash
docker exec supershadowvpn qrencode -t ansiutf8 < /root/clients/client1-wg.conf
```

### WireGuard Config File
```bash
docker exec supershadowvpn cat /root/clients/client1-wg.conf
```

### OpenVPN Config File
```bash
docker exec supershadowvpn cat /root/clients/client1.ovpn
```

## Container Management

### View Status
```bash
docker ps
docker logs supershadowvpn
```

### Stop/Start
```bash
docker stop supershadowvpn
docker start supershadowvpn
```

### Remove Container
```bash
docker-compose down
docker rmi supershadowvpn
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| CLIENT_COUNT | 3 | Number of client configs to generate |
| DNS_SERVERS | 1.1.1.1,1.0.0.1 | DNS servers for clients |
| WG_PORT | 51820 | WireGuard port |
| OVPN_PORT | 1194 | OpenVPN port |

## Ports Exposed

- **1194/udp** - OpenVPN
- **51820/udp** - WireGuard

## Volume Mounts

- `vpn_configs` - Client configuration files
- `vpn_certs` - OpenVPN certificates
- `vpn_wireguard` - WireGuard configurations

## Security Features

✅ **Privileged Container** - Required for VPN functionality
✅ **Network Admin Capabilities** - For iptables and routing
✅ **TUN Device Access** - For VPN tunneling
✅ **IP Forwarding** - Enabled automatically

## Troubleshooting

### Container Won't Start
```bash
# Check if TUN device exists
ls -la /dev/net/tun

# Verify Docker has necessary permissions
docker info | grep -i security
```

### No Internet Through VPN
```bash
# Check iptables rules
docker exec supershadowvpn iptables -t nat -L

# Verify IP forwarding
docker exec supershadowvpn cat /proc/sys/net/ipv4/ip_forward
```

### Can't Connect to VPN
```bash
# Check if services are running
docker exec supershadowvpn ps aux | grep -E "(openvpn|wg)"

# Check port binding
docker port supershadowvpn
```

## Production Deployment

For production use, consider:
- Using Docker secrets for certificates
- Setting up log rotation
- Implementing health checks
- Using a reverse proxy for additional security

## 🛡️ SuperShadowVPN Docker - Secure, Portable, Ready to Deploy!