BINARY_NAME=supershadowvpn
BUILD_DIR=build

.PHONY: all build server client clean install

all: build

build: server client

server:
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(BINARY_NAME)-server ./server

client:
	@mkdir -p $(BUILD_DIR)
	go build -o $(BUILD_DIR)/$(BINARY_NAME)-client ./client

clean:
	rm -rf $(BUILD_DIR)

install:
	go mod tidy
	go mod download

run-server:
	./$(BUILD_DIR)/$(BINARY_NAME)-server

run-client:
	./$(BUILD_DIR)/$(BINARY_NAME)-client