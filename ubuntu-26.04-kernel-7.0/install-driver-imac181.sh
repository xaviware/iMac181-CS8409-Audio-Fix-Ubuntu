#!/bin/bash
# Instalación del driver CS8409 Apple (snd_hda_macbookpro) vía DKMS
# iMac 18,1 - Ubuntu 26.04 LTS - Kernel 7.0.x
# iMac 18,2 - Zorin OS 18.1 - Linux Kernel 7.0.0-28-generic #28~24.04.1-Ubuntu

set -e

DRIVER_DIR="$HOME/snd_hda_macbookpro"
DRIVER_REPO="https://github.com/davidjo/snd_hda_macbookpro.git"

echo "========================================================="
echo "  Driver CS8409 Apple (snd_hda_macbookpro) via DKMS"
echo "  iMac 18,1 - Ubuntu 26.04 - Kernel $(uname -r)"
echo "========================================================="

echo ""
echo "[1/5] Instalando dependencias de compilación..."
KVER_BASE=$(uname -r | cut -d'-' -f1)

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "ID:$ID" # "ID:zorin"  Note: lowercase
    if [ "x$ID" == "xzorin" ]; then
        ## -- Zorin OS Ubuntu based Linux
        #sudo apt update
        #sudo apt install -y dkms gcc make

        echo "- NOTE: Within Zorin OS: Start Software Updater > Settings... > Zorin Software > enable Source code. So that we can download Linux kernel source code."

        ## -- get Linux source code, this expands to "./linux-hwe-7.0-7.0.0/"
        sudo apt-get source linux-image-unsigned-7.0.0-28-generic
        #sudo apt-get source linux-image-unsigned-7.0.0-30-generic                

        mv ./linux-hwe-7.0-7.0.0 ./linux-source-7.0.0

        ## create /usr/src/linux-source-7.0.0.tar.bz2 - but only sound module in this source archive
        ## needed because driver expect sound in "linux-source-7.0.0/sound/hda"
        sudo tar -C linux-source-7.0.0 -cjf /usr/src/linux-source-7.0.0.tar.bz2  --transform='s,^sound/hda,linux-source-7.0.0/sound/hda,' sound/hda

    fi
else
    ## -- assume standard Ubuntu
    sudo apt update
    sudo apt install -y dkms gcc make "linux-headers-$(uname -r)" "linux-source-${KVER_BASE}"
fi



if ! ls /usr/src/linux-source-*.tar.* >/dev/null 2>&1; then
    echo "⚠️  No se encontró el kernel source en /usr/src. Revisa que 'linux-source-${KVER_BASE}' se haya instalado."
    exit 1
fi

echo ""
echo "[2/5] Obteniendo driver snd_hda_macbookpro (rama master, con soporte kernel 7.0+)..."
if [ -d "$DRIVER_DIR/.git" ]; then
    git -C "$DRIVER_DIR" pull --ff-only
else
    git clone "$DRIVER_REPO" "$DRIVER_DIR"
fi

echo ""
echo "[3/5] Compilando e instalando el módulo vía DKMS (2-3 min)..."
cd "$DRIVER_DIR"
sudo ./install.cirrus.driver.sh -i

echo ""
echo "[4/5] Limpiando configuraciones de modprobe conflictivas..."
sudo rm -f /etc/modprobe.d/hda-jack-retask.conf
sudo rm -f /etc/modprobe.d/alsa-imac181.conf
sudo rm -f /etc/modprobe.d/cs8409-imac181.conf
sudo rm -f /etc/modprobe.d/iMac-cs8409-firmware.conf

echo ""
echo "[5/5] Escribiendo configuración limpia del codec..."
sudo tee /etc/modprobe.d/cs8409-imac.conf > /dev/null << 'EOF'
# iMac 18,1 CS8409 - configuración limpia
options snd-hda-intel position_fix=1 enable_msi=0 single_cmd=1 bdl_pos_adj=1
options snd-hda-codec-cirrus enable_msi=0
EOF

echo ""
echo "========================================================="
echo "  Instalación completa"
echo "========================================================="
echo ""
echo " - You know must have:"
echo "   /usr/lib/modules/7.0.0-28-generic/updates/dkms/snd-hda-codec-cs409.ko.zst"
echo ""
echo "dkms status:"
dkms status | grep snd_hda_macbookpro || echo "  (aún no aparece - revisa mensajes anteriores)"
echo ""
echo "Reinicia para aplicar:  sudo reboot"
echo ""
echo "Después del reinicio, verifica con:"
echo "  aplay -l"
echo "  speaker-test -c 2 -t wav"
echo "  journalctl -b 0 | grep -i cs8409 | head -10   # debe aparecer 'trying APPLE'"
