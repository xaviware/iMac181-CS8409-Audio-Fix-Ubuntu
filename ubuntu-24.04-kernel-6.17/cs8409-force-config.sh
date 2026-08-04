#!/bin/bash
# Force CS8409 configuration with HDA verbs

echo "🔧 Forcing CS8409 Configuration"
echo "================================="

# Force specific HDA verbs for CS8409
echo "Applying HDA verbs..."

# Enable output node 0x03
echo "Enabling output node 0x03..."
sudo hda-verb /dev/snd/hwC0D0 0x03 0x300 0x00 2>/dev/null || echo "hda-verb not available"

# Set amplifier gain
echo "Setting amplifier gain..."
sudo hda-verb /dev/snd/hwC0D0 0x03 0x707 0x00 2>/dev/null || echo "hda-verb not available"

# Enable IEC958
echo "Enabling IEC958..."
sudo hda-verb /dev/snd/hwC0D0 0x03 0x706 0x01 2>/dev/null || echo "hda-verb not available"

# Alternative: Use alsaucm if available
command -v alsaucm >/dev/null 2>&1 && {
    echo "Using alsaucm..."
    alsaucm -c 0 set _verb 0x03 0x300 0x00 2>/dev/null || true
    alsaucm -c 0 set _verb 0x03 0x707 0x00 2>/dev/null || true
}

# Reset and reload modules
echo "Resetting audio modules..."
sudo modprobe -r snd_hda_codec_cirrus 2>/dev/null || true
sudo modprobe -r snd_hda_intel 2>/dev/null || true
sleep 3

# Force reload with specific parameters
echo "Reloading with forced parameters..."
sudo modprobe snd_hda_intel model=imac181 position_fix=1 single_cmd=1

sleep 3

# Configure mixer
echo "Configuring mixer..."
amixer sset PCM 100% unmute 2>/dev/null || true

# Test with different approach
echo "Testing with forced configuration..."
speaker-test -D hw:0,0 -c 2 -t wav -l 2 2>/dev/null && {
    echo "✅ SUCCESS! Audio working with forced configuration"
} || {
    echo "❌ Still not working"
    echo ""
    echo "🔍 Possible issues:"
    echo "  - Hardware amplifier not powered"
    echo "  - Codec initialization incomplete"
    echo "  - Missing firmware/verbs"
    echo ""
    echo "💡 Try these commands:"
    echo "  sudo modprobe -r snd_hda_intel"
    echo "  sudo modprobe snd_hda_intel model=generic"
    echo "  speaker-test -D hw:0,0 -c 2 -t wav"
}
