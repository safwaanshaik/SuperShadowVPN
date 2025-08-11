package protocol

import (
	"net"
	"../core"
)

type ShadowsocksProxy struct {
	cipher *core.Cipher
	server string
}

func NewShadowsocks(key []byte, server string) (*ShadowsocksProxy, error) {
	cipher, err := core.NewAES256(key)
	if err != nil {
		return nil, err
	}
	return &ShadowsocksProxy{cipher: cipher, server: server}, nil
}

func (s *ShadowsocksProxy) Connect() (net.Conn, error) {
	conn, err := net.Dial("tcp", s.server)
	if err != nil {
		return nil, err
	}
	return &EncryptedConn{Conn: conn, cipher: s.cipher}, nil
}

type EncryptedConn struct {
	net.Conn
	cipher *core.Cipher
}

func (e *EncryptedConn) Write(b []byte) (int, error) {
	encrypted, err := e.cipher.Encrypt(b)
	if err != nil {
		return 0, err
	}
	return e.Conn.Write(encrypted)
}

func (e *EncryptedConn) Read(b []byte) (int, error) {
	encrypted := make([]byte, len(b)+32)
	n, err := e.Conn.Read(encrypted)
	if err != nil {
		return 0, err
	}
	decrypted, err := e.cipher.Decrypt(encrypted[:n])
	if err != nil {
		return 0, err
	}
	copy(b, decrypted)
	return len(decrypted), nil
}