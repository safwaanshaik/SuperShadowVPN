package main

import (
	"log"
	"net/http"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func main() {
	http.HandleFunc("/", serveHome)
	http.HandleFunc("/ws", handleWebSocket)
	
	log.Println("SuperShadowVPN web server starting on :8081")
	log.Fatal(http.ListenAndServe(":8081", nil))
}

func serveHome(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "index.html")
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade failed: ", err)
		return
	}
	defer conn.Close()
	
	log.Println("Client connected")
	
	for {
		_, message, err := conn.ReadMessage()
		if err != nil {
			log.Println("read failed:", err)
			break
		}
		
		log.Printf("Received: %s", message)
		
		// Echo back for now
		err = conn.WriteMessage(websocket.TextMessage, []byte("VPN proxy active"))
		if err != nil {
			log.Println("write failed:", err)
			break
		}
	}
}