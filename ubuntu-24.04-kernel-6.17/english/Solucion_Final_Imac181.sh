#!/bin/bash
# Final Solution for iMac 18,1 CS8409 - Kernel 6.17+
# No compilation - Direct ALSA configuration

echo "========================================================="
echo "       FINAL SOLUTION FOR IMAC 18,1 CS8409"
echo "       KERNEL 6.17+ - NO COMPILATION"
echo "========================================================="

echo "🔍 Detecting hardware..."
KERNEL_VERSION=$(uname -r)
echo "Kernel: $KERNEL_VERSION"

# Verify iMac 18,1
if lspci | grep -q "iMac18,1\|Apple Inc. iMac18,1"; then
    echo "✅ iMac 18,1 detected"
else
    echo "⚠️  iMac 18,1 not detected, continuing..."
fi

# Verify CS8409 codec
if cat /proc/asound/card0/codec#0 2>/dev/null | grep -q "CS8409\|Cirrus"; then
    echo "✅ CS8409 codec detected"
else
    echo "⚠️  CS8409 codec not detected, continuing..."
fi

echo ""
echo "🔧 Applying ALSA configuration for iMac 18,1..."

# Main ALSA configuration
sudo tee /etc/modprobe.d/alsa-imac181.conf > /dev/null << 'EOF'
# iMac 18,1 CS8409 Audio Configuration
options snd-hda-intel model=imac181 position_fix=1 enable_msi=0
options snd-hda-codec-cirrus enable_msi=0
EOF

# Additional CS8409 configuration
sudo tee /etc/modprobe.d/cs8409-imac181.conf > /dev/null << 'EOF'
# CS8409 specific fixes for iMac 18,1
options snd-hda-intel single_cmd=1 bdl_pos_adj=1
EOF

# Create basic PEQ firmware configuration
echo "📦 Creating basic PEQ configuration..."
FIRMWARE_DIR="/lib/firmware/hda-peq"
sudo mkdir -p "$FIRMWARE_DIR"

sudo tee "$FIRMWARE_DIR/cs8409-imac181-basic.conf" > /dev/null << 'EOF'
# iMac 18,1 CS8409 Basic Configuration
[codec]
0x106b0e00 0x106b0e00 0

# Volume and basic fixes
nid = 0x03; verb = 0x300; param = 0x00
nid = 0x11; verb = 0xf01; param = 0x00
EOF

# Configure modprobe for firmware
sudo tee /etc/modprobe.d/iMac-cs8409-firmware.conf > /dev/null << 'EOF'
options snd-hda-intel patch=hda-peq/cs8409-imac181-basic.conf
EOF

# Create audio setup script
echo "🎵 Creating audio setup script..."
sudo tee /usr/local/bin/setup-audio-imac181.sh > /dev/null << 'EOF'
#!/bin/bash
# Script to configure audio on iMac 18,1

echo "Configuring audio for iMac 18,1..."

# Wait for system to be ready
sleep 2

# Configure volume with amixer
amixer set Master 100% unmute 2>/dev/null || true
amixer set Speaker 100% unmute 2>/dev/null || true
amixer set Headphone 100% unmute 2>/dev/null || true
amixer set Front 100% unmute 2>/dev/null || true

# Disable auto-mute
amixer set 'Auto-Mute Mode' Disabled 2>/dev/null || true
amixer set 'Master Playback Switch' on 2>/dev/null || true

# Configure PCM
amixer set PCM 100% unmute 2>/dev/null || true

echo "Audio configured"
EOF

sudo chmod +x /usr/local/bin/setup-audio-imac181.sh

# Create systemd service
echo "🔄 Creating systemd service..."
sudo tee /etc/systemd/system/audio-imac181.service > /dev/null << 'EOF'
[Unit]
Description=Audio Setup for iMac 18,1
After=sound.target pulseaudio.service
Wants=sound.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/setup-audio-imac181.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enable service
sudo systemctl daemon-reload
sudo systemctl enable audio-imac181.service
sudo systemctl start audio-imac181.service

echo ""
echo "🔄 Reloading audio modules..."
sudo modprobe -r snd-hda-intel 2>/dev/null || true
sudo modprobe -r snd-hda-codec-cirrus 2>/dev/null || true
sudo modprobe snd-hda-intel

# Restart audio services
sudo systemctl restart pulseaudio 2>/dev/null || true
systemctl --user restart pulseaudio 2>/dev/null || true

echo ""
echo "========================================================="
echo "        FINAL SOLUTION APPLIED"
echo "========================================================="
echo ""
echo "✅ Configurations applied:"
echo "  - ALSA for iMac 18,1 (model=imac181)"
echo "  - Basic PEQ firmware"
echo "  - Automatic systemd service"
echo "  - Volume configuration script"
echo ""
echo "🔄 Please reboot the system:"
echo "  sudo reboot"
echo ""
echo "🔍 After reboot, verify with:"
echo "  aplay -l"
echo "  speaker-test -c 2 -t wav"
echo "  alsamixer (to adjust volume manually)"
echo ""
echo "🎛️  If no audio, run:"
echo "  sudo /usr/local/bin/setup-audio-imac181.sh"
echo "  alsamixer"
echo "  # Use arrow keys to navigate, 'm' to unmute"
echo ""
echo "📋 Detected devices:"
aplay -l 2>/dev/null | head -10 || echo "No devices detected yet"
