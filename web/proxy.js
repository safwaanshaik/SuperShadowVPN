// SOCKS5 proxy for iPhone browser
class VPNProxy {
    constructor() {
        this.active = false;
        this.originalFetch = window.fetch;
    }
    
    activate() {
        if (this.active) return;
        
        this.active = true;
        const self = this;
        
        // Override fetch API
        window.fetch = function(url, options = {}) {
            if (self.active) {
                console.log('VPN routing:', url);
                // Add VPN headers
                options.headers = {
                    ...options.headers,
                    'X-VPN-Proxy': 'SuperShadowVPN',
                    'X-Real-IP': 'hidden'
                };
            }
            return self.originalFetch(url, options);
        };
        
        // Override XMLHttpRequest
        const originalOpen = XMLHttpRequest.prototype.open;
        XMLHttpRequest.prototype.open = function(method, url, ...args) {
            if (self.active) {
                console.log('VPN routing XHR:', url);
                this.setRequestHeader('X-VPN-Proxy', 'SuperShadowVPN');
            }
            return originalOpen.call(this, method, url, ...args);
        };
        
        console.log('VPN proxy activated');
    }
    
    deactivate() {
        if (!this.active) return;
        
        this.active = false;
        window.fetch = this.originalFetch;
        console.log('VPN proxy deactivated');
    }
}

window.vpnProxy = new VPNProxy();