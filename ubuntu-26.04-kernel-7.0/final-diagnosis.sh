#!/bin/bash
# Final Diagnosis for CS8409 - Hardware vs Software Issue

echo "🔍 Final Diagnosis - CS8409"
echo "============================"

echo ""
echo "📊 Current Status:"
echo "Kernel: $(uname -r)"
echo "Ubuntu: $(lsb_release -d | cut -f2)"
echo "Codec: $(cat /proc/asound/card0/codec#0 | grep 'Codec:' | cut -d' ' -f2)"
echo "Subsystem: $(cat /proc/asound/card0/codec#0 | grep 'Subsystem Id:' | cut -d' ' -f2)"

echo ""
echo "🔧 Audio Configuration Check:"

# Check if audio is actually being processed
echo "1. Testing audio processing..."
speaker-test -D hw:0,0 -c 2 -t wav -l 1 2>&1 | grep -q "Front Left\|Front Right" && echo "✅ Audio is being processed" || echo "❌ Audio not processed"

# Check physical connections
echo ""
echo "2. Physical connection check:"
cat /proc/asound/card0/codec#0 | grep -A 5 "Node 0x03" | grep -q "Connection" && {
    CONNECTION=$(cat /proc/asound/card0/codec#0 | grep -A 5 "Node 0x03" | grep "Connection" | cut -d' ' -f3)
    echo "✅ Node 0x03 connected to: $CONNECTION"
} || echo "❌ No connection found for Node 0x03"

# Check amplifier status
echo ""
echo "3. Amplifier check:"
cat /proc/asound/card0/codec#0 | grep -q "Amp-Out caps" && {
    echo "✅ Amplifier detected"
} || echo "❌ No amplifier detected"

# Check power states
echo ""
echo "4. Power state check:"
POWER_STATE=$(cat /proc/asound/card0/codec#0 | grep "Power:" | head -1)
echo "Power state: $POWER_STATE"

echo ""
echo "🎯 Hardware Issue Indicators:"
ISSUES=0

# Check for common hardware problems
cat /proc/asound/card0/codec#0 | grep -q "0x106b0e00" || { echo "❌ Wrong subsystem ID (not iMac 18,1)"; ((ISSUES++)); }
cat /proc/asound/card0/codec#0 | grep -q "CS8409" || { echo "❌ Wrong codec detected"; ((ISSUES++)); }
cat /proc/asound/card0/codec#0 | grep -q "Node 0x03" || { echo "❌ Output node missing"; ((ISSUES++)); }

echo ""
if [ $ISSUES -eq 0 ]; then
    echo "✅ All hardware checks passed"
    echo ""
    echo "🔊 The issue is likely SOFTWARE/CONFIGURATION:"
    echo "  - Volume muted somewhere in the chain"
    echo "  - Wrong output device selected"
    echo "  - PipeWire/PulseAudio interference"
    echo ""
    echo "💡 Try these:"
    echo "  1. Check system volume: pavucontrol"
    echo "  2. Try HDMI output: aplay -D hw:0,3 test.wav"
    echo "  3. Try USB audio device"
else
    echo "❌ Hardware issues detected ($ISSUES issues)"
    echo ""
    echo "🔧 The CS8409 chip may have:"
    echo "  - Hardware failure"
    echo "  - Missing power to amplifier"
    echo "  - Incompatible firmware"
    echo ""
    echo "💡 Consider:"
    echo "  1. External USB audio adapter"
    echo "  2. Bluetooth headphones/speakers"
    echo "  3. Audio over HDMI to external display"
fi

echo ""
echo "📋 Final Recommendation:"
if command -v pactl >/dev/null 2>&1; then
    echo "Current audio sinks:"
    pactl list-sinks | grep -A 2 "Name:" | head -6
fi
