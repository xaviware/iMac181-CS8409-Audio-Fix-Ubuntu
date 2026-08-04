# iMac 18,1 CS8409 Audio Fix - Ubuntu 24.04 LTS y kernel 6.17+

> **Autor:** Javier Orellana (XaviWare)
> **GitHub:** https://github.com/xaviware/iMac181-CS8409-Audio-Fix-Ubuntu24.04-kernel6.17-
> **Hardware:** iMac 18,1 (21.5" 2017) — Cirrus Logic CS8409 — Subsystem ID: `0x106b0e00`
> **Sistema:** Ubuntu 24.04 LTS — Kernel 6.17.0-35-generic (probado hasta este kernel)

---

## El problema

El codec de audio del iMac 18,1 es un **Cirrus Logic CS8409**, un chip "bridge" que actúa como puente entre el bus HDA del procesador y los amplificadores internos de los altavoces.

El driver CS8409 incluido en el kernel Linux estándar (`snd-hda-codec-cs8409`) fue escrito para hardware **Dell** (Bullseye, Dolphin, Cyborg, Warlock) y no tiene ninguna entrada para el subsystem ID de Apple `0x106b0e00`. Sin el driver correcto, los altavoces internos no producen sonido.

### Por qué deja de funcionar después de una actualización de kernel

El driver correcto para este hardware es el módulo personalizado `snd-hda-codec-cs8409` del proyecto [davidjo/snd_hda_macbookpro](https://github.com/davidjo/snd_hda_macbookpro), que incluye soporte específico para Apple iMac 18,1/18,2/18,3 en su archivo `cirrus_apple.h`.

Este módulo se compila para un kernel específico. Si no fue instalado vía DKMS, **no se reconstruye automáticamente al actualizar el kernel** y el sistema cae de vuelta al driver estándar del kernel, que no funciona.

---

## Solución correcta

### Requisitos previos

```bash
sudo apt install dkms gcc make linux-headers-$(uname -r) linux-source-$(uname -r | cut -d'-' -f1)
```

Verificar que el kernel source esté disponible:

```bash
ls /usr/src/linux-source-*.tar.bz2
```

### Instalación del módulo via DKMS

```bash
cd /home/xaviware/snd_hda_macbookpro
sudo ./install.cirrus.driver.sh -i
```

El script tarda 2-3 minutos porque descarga/extrae el kernel source y compila el módulo. Al usar `-i` lo instala como DKMS, que **reconstruye automáticamente el módulo con cada actualización de kernel**.

### Limpiar configuraciones conflictivas de modprobe

Eliminar el archivo generado por `hda-jack-retask` (interfiere y no es necesario):

```bash
sudo rm -f /etc/modprobe.d/hda-jack-retask.conf
```

Dejar solo una configuración limpia para el codec:

```bash
sudo tee /etc/modprobe.d/cs8409-imac.conf > /dev/null << 'EOF'
# iMac 18,1 CS8409 - configuración limpia
options snd-hda-intel position_fix=1 enable_msi=0 single_cmd=1 bdl_pos_adj=1
options snd-hda-codec-cirrus enable_msi=0
EOF
```

### Reiniciar

```bash
sudo reboot
```

---

## Verificación

Después del reinicio:

```bash
# Confirmar que el módulo DKMS está activo
dkms status | grep snd_hda_macbookpro

# Verificar que el codec CS8409 es detectado
aplay -l

# Probar altavoces
speaker-test -c 2 -t wav

# Verificar mensajes del kernel (debe aparecer "cs8409_apple")
journalctl -b 0 | grep -i cs8409 | head -10
```

---

## Si el audio deja de funcionar tras una actualización de kernel

```bash
# Ver estado del módulo
dkms status

# Si aparece "not installed" para snd_hda_macbookpro en el nuevo kernel:
cd /home/xaviware/snd_hda_macbookpro
sudo ./install.cirrus.driver.sh -i
sudo reboot
```

Si el problema persiste:

```bash
# Verificar que no hay configs conflictivos
grep -h "patch=" /etc/modprobe.d/*.conf

# Si hay múltiples opciones patch=, conservar solo cs8409-imac.conf
# y eliminar los demás archivos que modifiquen snd-hda-intel
```

---

## Diagnóstico técnico (para referencia)

### Cómo distinguir si el driver Apple está activo

Con el driver correcto activo, el boot log muestra:

```
snd_hda_codec_cs8409: Primary patch_cs8409 NOT FOUND trying APPLE
```

Con el driver estándar del kernel (no funciona):

```
snd_hda_codec_cs8409 hdaudioC0D0: autoconfig for CS8409: line_outs=1 (0x2c) type:line
snd_hda_codec_cs8409 hdaudioC0D0:    speaker_outs=2 (0x24/0x25)
```

### Cómo verificar qué módulo está cargado

```bash
# Ruta del módulo activo
modinfo snd-hda-codec-cs8409 | grep filename

# Con driver Apple (correcto):
#   .../updates/dkms/snd-hda-codec-cs8409.ko.zst

# Con driver del kernel (no funciona para iMac):
#   .../kernel/sound/hda/codecs/cirrus/snd-hda-codec-cs8409.ko.zst
```

### Subsystem IDs Apple soportados por cirrus_apple.h

| Subsystem ID | Modelo |
|---|---|
| `0x106b0e00` | iMac 18,1 (21.5" 2017) |
| `0x106b0f00` | iMac 18,2 (21.5" 2017 Retina) |
| `0x106b1000` | iMac 18,3 (27" 2017) |
| `0x106b3300` | MacBook Pro 13,1 |
| `0x106b3900` | MacBook Pro 14,3 |

---

## Archivos en este repositorio

| Archivo | Descripción |
|---|---|
| `Solucion_Final_Imac181.sh` | Script original (enfoque incorrecto, no usar) |
| `fix-audio-now.sh` | Script de limpieza de modprobe (uso puntual) |
| `cs8409_verbs_config_181.txt` | Referencia de verbs HDA del codec |
| `hda-jack-retask.fw` | Pincfg alternativo (no necesario con driver Apple) |

> **Nota:** Los scripts originales del repositorio usaban `model=imac181` y firmwares PEQ que no se aplican correctamente. La solución real requiere el módulo DKMS `snd_hda_macbookpro`.

---

## Agradecimientos

- **[@davidjo](https://github.com/davidjo)** — Autor del driver `snd_hda_macbookpro` con soporte para Apple hardware y kernel 6.17+
- **[@egorenar](https://github.com/egorenar)** — Por el trabajo previo en `snd-hda-codec-cs8409` para Apple que sirvió de base

---

## Especificaciones del sistema de prueba

- **Hardware:** iMac 18,1 (21.5" 2017)
- **Audio Chip:** Cirrus Logic CS8409 — Subsystem ID `0x106b0e00`
- **Sistema:** Ubuntu 24.04 LTS
- **Kernel probado:** 6.17.0-35-generic
