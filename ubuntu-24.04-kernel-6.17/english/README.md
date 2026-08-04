# iMac 18,1 CS8409 Audio Fix - Ubuntu 24.04 LTS and kernel 6.17+

> **Author:** Javier Orellana (XaviWare)  
> **GitHub:** https://github.com/xaviware/iMac181-CS8409-Audio-Fix-Ubuntu24.04-kernel6.17-  
> **Project:** Definitive solution for CS8409 audio on iMac 18,1 with Ubuntu 24.04 LTS and kernel 6.17+

## 🎉 **PROBLEM SOLVED**

This project contains the definitive solution for audio problems on iMac 18,1 with Cirrus Logic CS8409 chip running Ubuntu 24.04 LTS and kernel 6.17+.

## 📁 **Important Files**

### ✅ **Working Solution**
- **`Solucion_Final_Imac181.sh`** - Definitive installation script
- **`cs8409_verbs_config_181.txt`** - PEQ configuration specific for iMac 18,1
- **`README.md`** - This documentation

## 🎯 **Successful Solution**

The problem was solved with **direct ALSA configuration** without needing to compile custom modules, thus avoiding compatibility issues with kernel 6.17+.

### **What worked?**
- ✅ CS8409 codec detection
- ✅ ALSA configuration for iMac 18,1 (model=imac181)
- ✅ Basic PEQ firmware
- ✅ Automatic systemd service
- ✅ Volume configuration script

## 🚀 **Installation**

For future installations or reinstallation:

```bash
sudo ./Solucion_Final_Imac181.sh
sudo reboot
```

## 🔍 **Verification**

After reboot:

```bash
# Check devices
aplay -l

# Test audio
speaker-test -c 2 -t wav

# Adjust volume if needed
alsamixer
```

## 📋 **Technical Specifications**

- **Hardware**: iMac 18,1 (2017)
- **Audio Chip**: Cirrus Logic CS8409
- **System**: Ubuntu 24.04 LTS
- **Kernel**: 6.17.0-14-generic
- **Subsystem ID**: 0x106b0e00

## 🔧 **Maintenance**

If audio stops working:

```bash
# Reapply configuration
sudo /usr/local/bin/setup-audio-imac181.sh

# Restart services
sudo systemctl restart audio-imac181.service
sudo reboot
```

## 📝 **Important Notes**

- This solution completely avoids module compilation
- Compatible with kernel 6.17+ and future versions
- Based on existing kernel ALSA
- Specific configuration for iMac 18,1

## 🙏 **Acknowledgments**

This solution was possible thanks to the work of:

- **[@egorenar](https://github.com/egorenar)** - For the `snd-hda-codec-cs8409` driver that served as the basis to understand CS8409 hardware
- **[@davidjo](https://github.com/davidjo)** - For the `snd_hda_macbookpro` driver with kernel 6.17+ support

Their work in the Linux community has been fundamental in solving audio problems on Apple hardware.

## 🎊 **Final Result**

Working audio on iMac 18,1 with:
- Internal speakers working
- Headphones functioning
- Full volume control
- No need for external drivers
