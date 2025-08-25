#!/bin/bash

echo "🔄 SuperShadowVPN Auto-Test Script"
echo "=================================="

SUCCESS_COUNT=0
TOTAL_TESTS=100

for i in $(seq 1 $TOTAL_TESTS); do
    echo "Test $i/$TOTAL_TESTS - $(date)"
    
    # Clean previous setup
    sudo wg-quick down wg0 2>/dev/null || true
    sudo pkill openvpn 2>/dev/null || true
    sudo rm -rf /etc/wireguard/wg0.conf /etc/openvpn/server 2>/dev/null || true
    
    # Run setup
    if sudo timeout 300 ./quick-setup.sh > /tmp/test_$i.log 2>&1; then
        # Test WireGuard
        if sudo wg show wg0 >/dev/null 2>&1; then
            # Test client config exists
            if [ -f /root/clients/client1-wg.conf ]; then
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
                echo "✅ Test $i: SUCCESS"
                
                # Show QR code on first success
                if [ $SUCCESS_COUNT -eq 1 ]; then
                    echo "📱 First successful QR code:"
                    sudo qrencode -t ansiutf8 < /root/clients/client1-wg.conf
                fi
            else
                echo "❌ Test $i: Config file missing"
            fi
        else
            echo "❌ Test $i: WireGuard not running"
        fi
    else
        echo "❌ Test $i: Setup failed"
    fi
    
    # Progress update every 10 tests
    if [ $((i % 10)) -eq 0 ]; then
        echo "Progress: $i/$TOTAL_TESTS completed, $SUCCESS_COUNT successful"
    fi
    
    sleep 2
done

echo ""
echo "🏁 Test Results:"
echo "================"
echo "Total Tests: $TOTAL_TESTS"
echo "Successful: $SUCCESS_COUNT"
echo "Failed: $((TOTAL_TESTS - SUCCESS_COUNT))"
echo "Success Rate: $((SUCCESS_COUNT * 100 / TOTAL_TESTS))%"

if [ $SUCCESS_COUNT -gt 0 ]; then
    echo ""
    echo "✅ SuperShadowVPN setup works!"
    echo "📱 Final working QR code:"
    sudo qrencode -t ansiutf8 < /root/clients/client1-wg.conf 2>/dev/null || echo "No config found"
else
    echo ""
    echo "❌ All tests failed. Check logs in /tmp/test_*.log"
fi