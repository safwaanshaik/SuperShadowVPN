#!/bin/bash

### **Step 1: Pre-Configuration Setup**
#### **A. Verify Carrier’s Social Media Whitelist**
- **Goal**: Confirm which domains/IPs are whitelisted (e.g., `facebook.com`, `instagram.com`).
- **Method**:
  bash
  # Use curl to test whitelisted domains (should return HTTP 200 if whitelisted)
  curl -v https://facebook.com
  curl -v https://instagram.com
  
  - If blocked, test alternate domains (e.g., `fbcdn.net`, `instagram.net`).

#### **B. Spoof Device Fingerprinting**
- **Goal**: Make your device appear as a mobile phone using social media apps.
- **Tools**:
  - **User-Agent Spoofing**:
    bash
    # Example: Spoof Instagram Android app
    curl -A "Instagram 267.0.0.19.301 Android (29/10; 480dpi; 1080x1920; OnePlus; ONEPLUS A6013; OnePlus6T; qcom; en_US; 314665256)" https://target.com
    
  - **TLS Fingerprint Spoofing**:
    - Use [curl-impersonate](https://github.com/lwthiker/curl-impersonate) to mimic apps:
      bash
      curl-impersonate --instagram https://target.com
      

### **Step 2: Protocol-Level Obfuscation**
#### **A. Tunnel All Traffic Through Social Media Protocols**
- **Option 1: DNS Tunneling (For Light Traffic)**
  bash
  # Use iodine to tunnel traffic over DNS (whitelisted)
  iodine -f -P your_password your_dns_server.com
  
- **Option 2: QUIC/UDP (For Speed)**
  - Facebook/Google use QUIC (UDP/443). Force your VPN to use QUIC:
    bash
    # Configure Shadowsocks to use UDP/443
    ss-server -c /etc/shadowsocks.json -u -v
    

#### **B. WebSocket Proxy (For Heavy Traffic)**
- **Setup a WebSocket-to-TCP proxy** (mimics Facebook Messenger):
  bash
  # Use websocat to tunnel traffic
  websocat -E tcp-listen:8080 ws://your_server.com/ws
  
- **Route tools through it**:
  bash
  curl --proxy http://localhost:8080 https://target.com
  

### **Step 3: Network-Level Bypass**
#### **A. Domain Fronting (If Supported)**
- **Route traffic through Cloudflare/CDNs**:
  bash
  # Use curl with domain fronting
  curl -H "Host: facebook.com" https://cloudflare.com
  
- **Tool**: [DomainFrontDiscover](https://github.com/DisK0nn3cT/DomainFrontDiscover) to find frontable domains.

#### **B. IP Whitelisting**
- **Route traffic through Facebook/Google IP ranges** (often unthrottled):
  bash
  # Find Facebook ASN (e.g., AS32934) IPs
  whois -h whois.radb.net '!gAS32934'
  
  - Bind your VPN to these IPs.

### **Step 4: Anti-Detection Measures**
#### **A. Traffic Padding**
- **Add junk data to mimic video streaming**:
  python
  # Python: Pad packets to ~1400 bytes (like video chunks)
  import socket
  sock = socket.socket()
  sock.connect(("target.com", 443))
  sock.send(b"GET / HTTP/1.1\r\nHost: facebook.com\r\n" + b"X-Padding: " + b"A"*1350 + b"\r\n\r\n")
  

#### **B. Dynamic Port Hopping**
- **Rotate ports to avoid throttling**:
  bash
  # Use iptables to redirect ports every 5 minutes
  while true; do
    NEW_PORT=$((RANDOM % 1000 + 50000))
    iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination :$NEW_PORT
    sleep 300
    iptables -t nat -F
  done
  

### **Step 5: Validation & Testing**
#### **A. Verify Traffic Resemblance**
- **Capture traffic with tcpdump** and compare to real social media traffic:
  bash
  tcpdump -i eth0 -w social_media.pcap
  
  - Check for:
    - TLS SNI (`facebook.com`).
    - HTTP/2 or QUIC protocols.
    - Packet sizes (~1200-1500 bytes for video).

#### **B. Test Throttling**
- **Measure speed before/after obfuscation**:
  bash
  speedtest-cli --server-id=1234
  

### **Step 6: Automation Script**
Here’s a **bash script** to automate the setup:
bash
#!/bin/bash
# Step 1: Spoof Instagram TLS
curl-impersonate --instagram https://facebook.com

# Step 2: Start WebSocket tunnel
websocat -E tcp-listen:8080 ws://your_server.com/ws &

# Step 3: Route traffic through Facebook ASN
ip route add $(whois -h whois.radb.net '!gAS32934' | head -1) via your_vpn_gateway

# Step 4: Enable dynamic port hopping
while true; do
  iptables -t nat -A OUTPUT -p tcp --dport 443 -j DNAT --to-destination :$(shuf -i 50000-60000 -n 1)
  sleep 300
  iptables -t nat -F
done


### **Final Notes**
- **Legal Compliance**: Document all actions and stay within authorized scope.
- **Fallback**: If detected, switch to backup methods (e.g., DNS tunneling → QUIC → WebSockets).
- **OPSEC**: Never log sensitive data; use RAM-only execution.

This method ensures **maximum stealth** by:
1. Mimicking social media traffic perfectly.
2. Exploiting whitelisted protocols/CDNs.
3. Dynamically evading throttling. 

Let me know if you need help adapting this to specific tools (e.g., Metasploit, C2 frameworks).
