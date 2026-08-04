# iMac 18,1 CS8409 Audio Fix

> **Autor:** Javier Orellana (XaviWare)
> **Hardware:** iMac 18,1 (21.5" 2017) — Cirrus Logic CS8409 — Subsystem ID: `0x106b0e00`

Solución para la falta de audio interno en el iMac 18,1 al usar Linux (Ubuntu). El driver estándar del kernel para el codec Cirrus Logic CS8409 está escrito para hardware Dell y no reconoce el subsystem ID de Apple, por lo que los altavoces internos no suenan sin el driver correcto (`snd_hda_macbookpro` vía DKMS).

Este repositorio se organiza por versión de Ubuntu/kernel, porque la solución hay que reinstalarla (o al menos revalidarla) cada vez que cambia el kernel mayor y el módulo DKMS queda huérfano.

## Versiones

| Carpeta | Sistema | Kernel | Estado |
|---|---|---|---|
| [`ubuntu-26.04-kernel-7.0/`](ubuntu-26.04-kernel-7.0/) | Ubuntu 26.04 LTS | 7.0.0-28-generic | **Actual — verificado en hardware real** |
| [`ubuntu-24.04-kernel-6.17/`](ubuntu-24.04-kernel-6.17/) | Ubuntu 24.04 LTS | 6.17.0-35-generic | Archivada |

Cada carpeta tiene su propio README con el diagnóstico, la instalación y la verificación específicas de esa combinación de sistema/kernel. El diagnóstico de fondo (codec Apple no soportado por el driver estándar) es el mismo en ambas.

## Créditos

- **[@davidjo](https://github.com/davidjo)** — Autor del driver [`snd_hda_macbookpro`](https://github.com/davidjo/snd_hda_macbookpro)
- **[@egorenar](https://github.com/egorenar)** — Trabajo previo en `snd-hda-codec-cs8409` para Apple
