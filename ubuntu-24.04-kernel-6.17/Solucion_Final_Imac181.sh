#!/bin/bash
# Solución Final para iMac 18,1 CS8409 - Kernel 6.17+
# Sin compilación - Configuración ALSA directa

echo "========================================================="
echo "       SOLUCIÓN FINAL PARA IMAC 18,1 CS8409"
echo "       KERNEL 6.17+ - SIN COMPILACIÓN"
echo "========================================================="

echo "🔍 Detectando hardware..."
KERNEL_VERSION=$(uname -r)
echo "Kernel: $KERNEL_VERSION"

# Verificar iMac 18,1
if lspci | grep -q "iMac18,1\|Apple Inc. iMac18,1"; then
    echo "✅ iMac 18,1 detectado"
else
    echo "⚠️  iMac 18,1 no detectado, continuando..."
fi

# Verificar codec CS8409
if cat /proc/asound/card0/codec#0 2>/dev/null | grep -q "CS8409\|Cirrus"; then
    echo "✅ Codec CS8409 detectado"
else
    echo "⚠️  Codec CS8409 no detectado, continuando..."
fi

echo ""
echo "🔧 Aplicando configuración ALSA para iMac 18,1..."

# Configuración principal ALSA
sudo tee /etc/modprobe.d/alsa-imac181.conf > /dev/null << 'EOF'
# iMac 18,1 CS8409 Audio Configuration
options snd-hda-intel model=imac181 position_fix=1 enable_msi=0
options snd-hda-codec-cirrus enable_msi=0
EOF

# Configuración adicional para CS8409
sudo tee /etc/modprobe.d/cs8409-imac181.conf > /dev/null << 'EOF'
# CS8409 specific fixes for iMac 18,1
options snd-hda-intel single_cmd=1 bdl_pos_adj=1
EOF

# Configuración de firmware PEQ básica
echo "📦 Creando configuración PEQ básica..."
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

# Configurar modprobe para firmware
sudo tee /etc/modprobe.d/iMac-cs8409-firmware.conf > /dev/null << 'EOF'
options snd-hda-intel patch=hda-peq/cs8409-imac181-basic.conf
EOF

# Crear script de configuración de audio
echo "🎵 Creando script de configuración de audio..."
sudo tee /usr/local/bin/setup-audio-imac181.sh > /dev/null << 'EOF'
#!/bin/bash
# Script para configurar audio en iMac 18,1

echo "Configurando audio para iMac 18,1..."

# Esperar a que el sistema esté listo
sleep 2

# Configurar volumen con amixer
amixer set Master 100% unmute 2>/dev/null || true
amixer set Speaker 100% unmute 2>/dev/null || true
amixer set Headphone 100% unmute 2>/dev/null || true
amixer set Front 100% unmute 2>/dev/null || true

# Desactivar auto-mute
amixer set 'Auto-Mute Mode' Disabled 2>/dev/null || true
amixer set 'Master Playback Switch' on 2>/dev/null || true

# Configurar PCM
amixer set PCM 100% unmute 2>/dev/null || true

echo "Audio configurado"
EOF

sudo chmod +x /usr/local/bin/setup-audio-imac181.sh

# Crear servicio systemd
echo "🔄 Creando servicio systemd..."
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

# Activar servicio
sudo systemctl daemon-reload
sudo systemctl enable audio-imac181.service
sudo systemctl start audio-imac181.service

echo ""
echo "🔄 Recargando módulos de audio..."
sudo modprobe -r snd-hda-intel 2>/dev/null || true
sudo modprobe -r snd-hda-codec-cirrus 2>/dev/null || true
sudo modprobe snd-hda-intel

# Reiniciar servicios de audio
sudo systemctl restart pulseaudio 2>/dev/null || true
systemctl --user restart pulseaudio 2>/dev/null || true

echo ""
echo "========================================================="
echo "        SOLUCIÓN FINAL APLICADA"
echo "========================================================="
echo ""
echo "✅ Configuraciones aplicadas:"
echo "  - ALSA para iMac 18,1 (model=imac181)"
echo "  - Firmware PEQ básico"
echo "  - Servicio systemd automático"
echo "  - Script de configuración de volumen"
echo ""
echo "🔄 Por favor reinicia el sistema:"
echo "  sudo reboot"
echo ""
echo "🔍 Después del reinicio, verifica con:"
echo "  aplay -l"
echo "  speaker-test -c 2 -t wav"
echo "  alsamixer (para ajustar volumen manualmente)"
echo ""
echo "🎛️  Si no hay audio, ejecuta:"
echo "  sudo /usr/local/bin/setup-audio-imac181.sh"
echo "  alsamixer"
echo "  # Usa flechas para navegar, 'm' para desmutear"
echo ""
echo "📋 Dispositivos detectados:"
aplay -l 2>/dev/null | head -10 || echo "No se detectaron dispositivos aún"
