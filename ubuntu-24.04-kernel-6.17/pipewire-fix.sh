#!/bin/bash
# Fix PipeWire blocking CS8409 audio

echo "🔧 PipeWire Audio Fix - iMac 18,1"
echo "==================================="

# Stop PipeWire temporarily
echo "Stopping PipeWire..."
systemctl --user stop pipewire
systemctl --user stop wireplumb
sleep 2

# Configure ALSA directly
echo "Configuring ALSA..."
amixer sset PCM 100% unmute 2>/dev/null || true
amixer sset 'IEC958' on 2>/dev/null || true

# Test audio
echo "Testing audio..."
speaker-test -D hw:0,0 -c 2 -t wav -l 2 2>/dev/null && {
    echo "✅ Audio working!"
    echo "To make permanent:"
    echo "  sudo systemctl --user disable pipewire"
    echo "  sudo systemctl --user disable wireplumb"
} || {
    echo "❌ Audio still not working"
    echo "Restarting PipeWire..."
    systemctl --user start pipewire
    systemctl --user start wireplumb
}

echo ""
echo "📋 Available devices:"
aplay -l | head -3
