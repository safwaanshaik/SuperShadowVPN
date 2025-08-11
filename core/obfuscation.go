package core

import (
	"crypto/rand"
	"encoding/binary"
)

type Obfuscator struct {
	key []byte
}

func NewObfuscator(key []byte) *Obfuscator {
	return &Obfuscator{key: key}
}

func (o *Obfuscator) Obfuscate(data []byte) []byte {
	// Simple XOR obfuscation with random padding
	padding := make([]byte, 16)
	rand.Read(padding)
	
	result := make([]byte, len(data)+20)
	binary.LittleEndian.PutUint32(result[:4], uint32(len(data)))
	copy(result[4:20], padding)
	
	for i, b := range data {
		result[i+20] = b ^ o.key[i%len(o.key)] ^ padding[i%16]
	}
	
	return result
}

func (o *Obfuscator) Deobfuscate(data []byte) []byte {
	if len(data) < 20 {
		return nil
	}
	
	length := binary.LittleEndian.Uint32(data[:4])
	padding := data[4:20]
	encrypted := data[20:]
	
	if uint32(len(encrypted)) != length {
		return nil
	}
	
	result := make([]byte, length)
	for i := range result {
		result[i] = encrypted[i] ^ o.key[i%len(o.key)] ^ padding[i%16]
	}
	
	return result
}