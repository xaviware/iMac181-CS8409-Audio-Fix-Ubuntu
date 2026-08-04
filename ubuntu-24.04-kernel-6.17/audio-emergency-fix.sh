#!/bin/bash
# Emergency Audio Fix for iMac 18,1 CS8409

echo "🔧 Emergency Audio Fix - iMac 18,1"
echo "=================================="

# Kill all audio processes
echo "Stopping audio services..."
sudo pkill -f pulseaudio 2>/dev/null || true
sudo pkill -f pipewire 2>/dev/null || true

# Reset audio modules
echo "Resetting audio modules..."
sudo modprobe -r snd_hda_codec_cirrus 2>/dev/null || true
sudo modprobe -r snd_hda_intel 2>/dev/null || true
sleep 2

# Reload modules
echo "Reloading audio modules..."
sudo modprobe snd_hda_intel model=imac181 position_fix=1
sleep 3

# Force PCM configuration
echo "Configuring PCM controls..."
amixer sset PCM 100% unmute 2>/dev/null || true
amixer sset 'IEC958' on 2>/dev/null || true

# Test with direct device
echo "Testing direct device output..."
speaker-test -D hw:0,0 -c 2 -t wav -l 3 2>/dev/null || {
    echo "❌ Direct device test failed"
    echo "Trying alternative device..."
    speaker-test -D default -c 2 -t wav -l 2 2>/dev/null || {
        echo "❌ All tests failed"
        echo "🔄 Reboot may be required"
    }
}

echo ""
echo "📋 Available devices:"
aplay -l | head -5

echo ""
echo "🎛️ Current mixer controls:"
amixer scontrols | head -5

echo ""
echo "If still no audio, try:"
echo "  1. Reboot: sudo reboot"
echo "  2. Check alsamixer: alsamixer"
echo "  3. Test different outputs:"
