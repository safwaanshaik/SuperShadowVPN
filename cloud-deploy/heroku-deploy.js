// Heroku FREE Web-based VPN Proxy
const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const app = express();
const PORT = process.env.PORT || 3000;

// SuperShadowVPN Web Proxy
app.use('/proxy', createProxyMiddleware({
  target: 'https://httpbin.org',
  changeOrigin: true,
  pathRewrite: {
    '^/proxy': '',
  },
  onProxyReq: (proxyReq, req, res) => {
    proxyReq.setHeader('X-SuperShadowVPN', 'Active');
    proxyReq.setHeader('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36');
  }
}));

// VPN Status page
app.get('/', (req, res) => {
  res.send(`
    <h1>🛡️ SuperShadowVPN FREE Cloud</h1>
    <p>Status: <span style="color:green">ACTIVE</span></p>
    <p>Server: Heroku Free Tier</p>
    <p>Proxy: /proxy/[url]</p>
    <p>Example: <a href="/proxy/ip">/proxy/ip</a></p>
  `);
});

app.listen(PORT, () => {
  console.log(`🚀 SuperShadowVPN running on port ${PORT}`);
});

// package.json
const packageJson = {
  "name": "supershadowvpn-free",
  "version": "1.0.0",
  "scripts": {
    "start": "node heroku-deploy.js"
  },
  "dependencies": {
    "express": "^4.18.0",
    "http-proxy-middleware": "^2.0.0"
  }
};