package main

import (
	"log"
	"net"
	"../core"
	"../protocol"
)

type VPNServer struct {
	cipher *core.Cipher
	port   string
}

func NewServer(key []byte, port string) (*VPNServer, error) {
	cipher, err := core.NewAES256(key)
	if err != nil {
		return nil, err
	}
	return &VPNServer{cipher: cipher, port: port}, nil
}

func (s *VPNServer) Start() error {
	listener, err := net.Listen("tcp", ":"+s.port)
	if err != nil {
		return err
	}
	defer listener.Close()
	
	log.Printf("SuperShadowVPN server listening on port %s", s.port)
	
	for {
		conn, err := listener.Accept()
		if err != nil {
			continue
		}
		go s.handleClient(conn)
	}
}

func (s *VPNServer) handleClient(conn net.Conn) {
	defer conn.Close()
	
	encConn := &protocol.EncryptedConn{Conn: conn, cipher: s.cipher}
	
	// Proxy traffic
	buffer := make([]byte, 4096)
	for {
		n, err := encConn.Read(buffer)
		if err != nil {
			break
		}
		
		// Forward to destination
		target, err := net.Dial("tcp", "8.8.8.8:53")
		if err != nil {
			continue
		}
		target.Write(buffer[:n])
		target.Close()
	}
}

func main() {
	key := make([]byte, 32)
	server, err := NewServer(key, "8080")
	if err != nil {
		log.Fatal(err)
	}
	server.Start()
}