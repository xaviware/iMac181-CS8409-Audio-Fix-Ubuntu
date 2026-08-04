# iMac 18,1 CS8409 Audio Fix - Ubuntu 26.04 LTS y kernel 7.0+

> **Autor:** Javier Orellana (XaviWare)
> **Hardware:** iMac 18,1 (21.5" 2017) — Cirrus Logic CS8409 — Subsystem ID: `0x106b0e00`
> **Sistema:** Ubuntu 26.04 LTS (Resolute) — Kernel 7.0.0-28-generic (probado hasta este kernel)
> **Versión anterior:** [ubuntu-24.04-kernel-6.17/](../ubuntu-24.04-kernel-6.17/) (mismo diagnóstico, kernels 6.x)
> **Estado:** ✅ Verificado — `install-driver-imac181.sh` probado en hardware real, audio funcionando tras reinicio.

---

## El problema

Igual que en la versión anterior de este repo: el driver CS8409 incluido en el kernel Linux estándar (`snd-hda-codec-cs8409`) fue escrito para hardware **Dell** y no reconoce el subsystem ID de Apple `0x106b0e00`. Sin el driver correcto, los altavoces internos no producen sonido (línea `speaker_outs=0` en el autoconfig del kernel).

Tras actualizar de Ubuntu 24.04/kernel 6.17 a **Ubuntu 26.04/kernel 7.0**, el módulo DKMS anterior queda huérfano (compilado para un kernel que ya no existe) y el sistema vuelve a cargar el driver estándar del kernel. Hay que recompilar contra el kernel 7.0.

## Qué cambió respecto a kernel 6.17

- El proyecto upstream [davidjo/snd_hda_macbookpro](https://github.com/davidjo/snd_hda_macbookpro) agregó soporte explícito para kernel 7.0+ en dos commits (abril y mayo de 2026): ajuste del chequeo de versión y un fix de DKMS para que `uname -r` no sobreescriba el kernel objetivo. **No hace falta parchear código fuente**, solo usar la rama `master` actual del driver.
- El propio autor del driver confirma haberlo probado en Ubuntu 26.04 sin cambios adicionales.
- El paquete de kernel source en Ubuntu sigue el mismo patrón que en 24.04: `linux-source-$(uname -r | cut -d'-' -f1)` → en este caso `linux-source-7.0.0`.
- En algunos reportes de otras distros el build falló porque `cdn.kernel.org` tuvo caídas puntuales en la ruta `/v7.x/` (mayo-julio 2026, ya resuelto). En Ubuntu esto no debería afectar porque el script usa primero el kernel source local instalado vía `apt` en vez de descargarlo.

## Instalación

Script automatizado que reproduce los mismos pasos que la versión 24.04 (dependencias, DKMS, limpieza de modprobe) pero apuntando al kernel 7.0.0 y al driver `master` actualizado:

```bash
./install-driver-imac181.sh
```

Qué hace:

1. Instala `dkms gcc make linux-headers-$(uname -r) linux-source-7.0.0`.
2. Clona (o actualiza si ya existe) `snd_hda_macbookpro` en `~/snd_hda_macbookpro`.
3. Compila e instala el módulo con `sudo ./install.cirrus.driver.sh -i` (DKMS, se reconstruye solo en cada actualización de kernel).
4. Elimina configuraciones de modprobe conflictivas (`hda-jack-retask.conf` y los archivos del enfoque incorrecto de la v1).
5. Escribe `/etc/modprobe.d/cs8409-imac.conf` con la configuración limpia.

Al terminar:

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

# Verificar mensajes del kernel (debe aparecer "trying APPLE")
journalctl -b 0 | grep -i cs8409 | head -10
```

Con el driver correcto activo, el boot log muestra:

```
snd_hda_codec_cs8409: Primary patch_cs8409 NOT FOUND trying APPLE
```

Con el driver estándar del kernel (no funciona, es lo que se ve por defecto tras cada salto de kernel sin DKMS):

```
snd_hda_codec_cs8409 hdaudioC0D0: autoconfig for CS8409: line_outs=2 (0x24/0x25/0x0/0x0/0x0) type:speaker
snd_hda_codec_cs8409 hdaudioC0D0:    speaker_outs=0 (0x0/0x0/0x0/0x0/0x0)
```

Ruta del módulo activo:

```bash
modinfo snd-hda-codec-cs8409 | grep filename

# Con driver Apple (correcto):
#   .../updates/dkms/snd-hda-codec-cs8409.ko.zst

# Con driver del kernel (no funciona para iMac):
#   .../kernel/sound/hda/codecs/cirrus/snd-hda-codec-cs8409.ko.zst
```

---

## Si el audio deja de funcionar tras una actualización de kernel

```bash
dkms status

# Si aparece "not installed" para snd_hda_macbookpro en el nuevo kernel:
cd ~/snd_hda_macbookpro
git pull --ff-only
sudo ./install.cirrus.driver.sh -i
sudo reboot
```

Si el problema persiste, revisar configs conflictivos:

```bash
grep -h "patch=" /etc/modprobe.d/*.conf
# Conservar solo cs8409-imac.conf y eliminar el resto
```

Nota de la comunidad upstream (issues #176, #178, #196 del repo del driver): en distros que compilan el kernel con `clang` (p. ej. CachyOS) el `install.cirrus.driver.sh` puede necesitar `CC=clang LD=ld.lld LLVM=1` extra en el `make`. **No aplica a Ubuntu** (usa gcc por defecto), se deja como referencia si en el futuro se prueba en otra distro derivada.

---

## Archivos en este repositorio

| Archivo | Descripción |
|---|---|
| `install-driver-imac181.sh` | Script de instalación automatizada del driver DKMS para kernel 7.0+ (la solución) |
| `final-diagnosis.sh` | Diagnóstico genérico hardware vs. software (subsystem ID, nodo de conexión, amplificador) |
| `pipewire-fix.sh` | Utilidad puntual para cuando PipeWire bloquea el audio, independiente del driver CS8409 |

---

## Agradecimientos

- **[@davidjo](https://github.com/davidjo)** — Autor del driver `snd_hda_macbookpro`, con soporte para Apple hardware y kernel 7.0+
- **[@egorenar](https://github.com/egorenar)** — Por el trabajo previo en `snd-hda-codec-cs8409` para Apple que sirvió de base

---

## Especificaciones del sistema de prueba

- **Hardware:** iMac 18,1 (21.5" 2017)
- **Audio Chip:** Cirrus Logic CS8409 — Subsystem ID `0x106b0e00`
- **Sistema:** Ubuntu 26.04 LTS (Resolute)
- **Kernel probado:** 7.0.0-28-generic
