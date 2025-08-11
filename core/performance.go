package core

import (
	"sync"
	"time"
)

type LoadBalancer struct {
	servers []string
	current int
	mu      sync.RWMutex
	health  map[string]bool
}

func NewLoadBalancer(servers []string) *LoadBalancer {
	return &LoadBalancer{
		servers: servers,
		health:  make(map[string]bool),
	}
}

func (lb *LoadBalancer) GetServer() string {
	lb.mu.Lock()
	defer lb.mu.Unlock()
	
	// Round-robin with health check
	for i := 0; i < len(lb.servers); i++ {
		server := lb.servers[lb.current]
		lb.current = (lb.current + 1) % len(lb.servers)
		
		if healthy, exists := lb.health[server]; !exists || healthy {
			return server
		}
	}
	
	// Fallback to first server
	return lb.servers[0]
}

func (lb *LoadBalancer) MarkUnhealthy(server string) {
	lb.mu.Lock()
	lb.health[server] = false
	lb.mu.Unlock()
	
	// Auto-recovery after 30 seconds
	go func() {
		time.Sleep(30 * time.Second)
		lb.mu.Lock()
		lb.health[server] = true
		lb.mu.Unlock()
	}()
}

type ConnectionPool struct {
	pool chan interface{}
	max  int
}

func NewConnectionPool(max int) *ConnectionPool {
	return &ConnectionPool{
		pool: make(chan interface{}, max),
		max:  max,
	}
}

func (cp *ConnectionPool) Get() interface{} {
	select {
	case conn := <-cp.pool:
		return conn
	default:
		return nil
	}
}

func (cp *ConnectionPool) Put(conn interface{}) {
	select {
	case cp.pool <- conn:
	default:
		// Pool full, discard
	}
}