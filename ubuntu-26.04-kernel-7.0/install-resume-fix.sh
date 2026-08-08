#!/bin/bash
# Instala el hook de systemd-sleep que arregla la pérdida de audio tras
# deep sleep (S3) en el iMac 18,1 CS8409. Ver cs8409-resume-fix para el
# diagnóstico completo.
set -e

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="/usr/lib/systemd/system-sleep/cs8409-resume-fix"

echo "Instalando hook de resume en $DEST..."
sudo install -o root -g root -m 0755 "$SRC_DIR/cs8409-resume-fix" "$DEST"

echo ""
echo "Listo. A partir de ahora, cada vez que la máquina despierte de"
echo "suspender (S3), el controlador HDA se reiniciará automáticamente"
echo "para reprogramar los amplificadores del CS8409."
echo ""
echo "Para aplicar el arreglo ahora mismo sin esperar a suspender de nuevo:"
echo "  sudo /usr/lib/systemd/system-sleep/cs8409-resume-fix post"
echo ""
echo "Para probarlo de verdad:"
echo "  systemctl suspend"
echo "  # espera a que despierte y prueba: speaker-test -c 2 -t wav"
echo ""
echo "Log del hook en cada resume:"
echo "  journalctl -t cs8409-resume-fix"
