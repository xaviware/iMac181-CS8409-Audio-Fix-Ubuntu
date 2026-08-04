#!/bin/bash
# Fix audio for iMac 18,1 CS8409 - Volumen y configuracion limpias
set -e

echo "=================================="
echo "   FIX DE AUDIO iMac 18,1 CS8409"
echo "=================================="

# 1. Consolidar modprobe.d en un solo archivo limpio
echo "[1/5] Consolidando configuraciones modprobe..."

cat > /etc/modprobe.d/cs8409-imac.conf << 'MODPROBE_EOF'
# iMac 18,1 CS8409 Audio - Clean consolidated config
options snd-hda-intel model=imac27 position_fix=1 enable_msi=0 single_cmd=1 bdl_pos_adj=1
options snd-hda-intel patch=hda-peq/cs8409-imac181-basic.conf
options snd-hda-codec-cirrus enable_msi=0
MODPROBE_EOF

# 2. Eliminar archivos redundantes/rotos
echo "[2/5] Eliminando archivos redundantes y conflictivos..."

for f in alsa-imac181.conf cs8409-inject.conf cs8409-imac181.conf iMac-cs8409-firmware.conf; do
    if [ -f "/etc/modprobe.d/$f" ]; then
        rm -v "/etc/modprobe.d/$f"
    fi
done

# Quitar la linea model=imac27 duplicada de alsa-base.conf (ya esta en cs8409-imac.conf)
if grep -q "options snd-hda-intel model=imac27" /etc/modprobe.d/alsa-base.conf; then
    sed -i '/^options snd-hda-intel model=imac27/d' /etc/modprobe.d/alsa-base.conf
    echo "Linea model=imac27 eliminada de alsa-base.conf"
fi

# 3. Asegurar que el firmware PEQ existe
echo "[3/5] Verificando firmware PEQ..."
mkdir -p /lib/firmware/hda-peq

if [ ! -f /lib/firmware/hda-peq/cs8409-imac181-basic.conf ]; then
    cat > /lib/firmware/hda-peq/cs8409-imac181-basic.conf << 'PEQ_EOF'
# iMac 18,1 CS8409 Basic Configuration
[codec]
0x106b0e00 0x106b0e00 0

# Volume and basic fixes
nid = 0x03; verb = 0x300; param = 0x00
nid = 0x11; verb = 0xf01; param = 0x00
PEQ_EOF
    echo "Firmware PEQ creado"
else
    echo "Firmware PEQ ya existe"
fi

# 4. Persistir volumen ALSA entre reinicios
echo "[4/5] Guardando estado de volumen ALSA..."

# Set volume al maximo
amixer set PCM 100% unmute 2>/dev/null || true
amixer set Master 100% unmute 2>/dev/null || true
amixer set Speaker 100% unmute 2>/dev/null || true
amixer set Headphone 100% unmute 2>/dev/null || true
amixer set Front 100% unmute 2>/dev/null || true
amixer set 'Auto-Mute Mode' Disabled 2>/dev/null || true

# Guardar estado para que persista
alsactl store

# Habilitar el servicio alsa-state para restaurar en boot
systemctl enable alsa-state 2>/dev/null || systemctl enable alsa-restore 2>/dev/null || true

echo "Volumen 100% guardado"

# 5. Recargar modulo de audio
echo "[5/5] Recargando modulo de audio..."

modprobe -r snd-hda-intel 2>/dev/null || true
sleep 2
modprobe snd-hda-intel
sleep 2

# Restaurar estado alsa
alsactl restore 2>/dev/null || true

# Reiniciar servicios de audio de usuario
systemctl --user restart pipewire 2>/dev/null || true
systemctl --user restart wireplumber 2>/dev/null || true
sleep 2

echo ""
echo "=================================="
echo "   FIX COMPLETADO"
echo "=================================="
echo ""
echo "Verifica:"
echo "  aplay -l"
echo "  speaker-test -c 2 -t wav"
echo ""
echo "Si aun no se escucha, reinicia:"
echo "  sudo reboot"
