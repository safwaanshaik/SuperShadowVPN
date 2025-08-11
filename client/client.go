package main

import (
	"log"
	"net"
	"../core"
	"../protocol"
)

type VPNClient struct {
	proxy  *protocol.ShadowsocksProxy
	local  string
}

func NewClient(key []byte, server, local string) (*VPNClient, error) {
	proxy, err := protocol.NewShadowsocks(key, server)
	if err != nil {
		return nil, err
	}
	return &VPNClient{proxy: proxy, local: local}, nil
}

func (c *VPNClient) Start() error {
	listener, err := net.Listen("tcp", c.local)
	if err != nil {
		return err
	}
	defer listener.Close()
	
	log.Printf("SuperShadowVPN client listening on %s", c.local)
	
	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}
		go c.handleConnection(conn)
	}
}

func (c *VPNClient) handleConnection(local net.Conn) {
	defer local.Close()
	
	remote, err := c.proxy.Connect()
	if err != nil {
		return
	}
	defer remote.Close()
	
	// Bidirectional proxy
	go func() {
		buffer := make([]byte, 4096)
		for {
			n, err := local.Read(buffer)
			if err != nil {
				break
			}
			remote.Write(buffer[:n])
		}
	}()
	
	buffer := make([]byte, 4096)
	for {
		n, err := remote.Read(buffer)
		if err != nil {
			break
		}
		local.Write(buffer[:n])
	}
}

func main() {
	key := make([]byte, 32)
	client, err := NewClient(key, "localhost:8080", "127.0.0.1:1080")
	if err != nil {
		log.Fatal(err)
	}
	client.Start()
}