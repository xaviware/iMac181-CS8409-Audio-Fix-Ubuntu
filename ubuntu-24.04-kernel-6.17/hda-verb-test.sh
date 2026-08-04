#!/bin/bash
# Test HDA verbs for CS8409

echo "🔧 Testing HDA Verbs - CS8409"
echo "================================"

# Test different output nodes
echo "Testing Node 0x03..."
speaker-test -D hw:0,0 -c 2 -t wav -l 1 2>/dev/null && echo "✅ Node 0x03 OK" || echo "❌ Node 0x03 Failed"

echo "Testing Node 0x04..."
speaker-test -D hw:0,1 -c 2 -t wav -l 1 2>/dev/null && echo "✅ Node 0x04 OK" || echo "❌ Node 0x04 Failed"

echo "Testing Node 0x05..."
speaker-test -D hw:0,2 -c 2 -t wav -l 1 2>/dev/null && echo "✅ Node 0x05 OK" || echo "❌ Node 0x05 Failed"

echo ""
echo "🎛️ Testing different configurations..."

# Test with different sample rates
echo "Testing 44100 Hz..."
speaker-test -D hw:0,0 -r 44100 -c 2 -t wav -l 1 2>/dev/null && echo "✅ 44100 Hz OK" || echo "❌ 44100 Hz Failed"

echo "Testing 22050 Hz..."
speaker-test -D hw:0,0 -r 22050 -c 2 -t wav -l 1 2>/dev/null && echo "✅ 22050 Hz OK" || echo "❌ 22050 Hz Failed"

# Test mono
echo "Testing mono..."
speaker-test -D hw:0,0 -c 1 -t wav -l 1 2>/dev/null && echo "✅ Mono OK" || echo "❌ Mono Failed"

echo ""
echo "📊 Current codec connections:"
cat /proc/asound/card0/codec#0 | grep -A 5 "Connection" | head -10

echo ""
echo "🔍 If all tests fail, the issue may be:"
echo "  - Hardware routing problem"
echo "  - Missing amplifier configuration"
echo "  - Codec initialization issue"
