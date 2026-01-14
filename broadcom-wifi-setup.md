# Broadcom BCM4360 WiFi Setup - MacBook on Bluefin

## Hardware
- Network controller: Broadcom BCM4360 802.11ac [14e4:43a0]
- Subsystem: Apple Inc. [106b:0134]

## What was tried (failed)
1. Confirmed RPM Fusion (free + nonfree) already installed
2. Attempted `rpm-ostree install broadcom-wl` - failed due to akmod trying to build for kernel 6.17.4 without kernel-devel
3. Used Universal Blue's built-in command: `ujust configure-broadcom-wl enable` - appeared to succeed but **did not work after reboot**

## Solution: Added to custom image
Added `broadcom-wl` package to `build_files/build.sh` to bake the driver into the custom image at build time.

## Current status
- Driver added to build.sh, **rebuild and rebase required**

## After reboot - verify with
```bash
# Check if wl module is loaded
lsmod | grep wl

# Check device status
nmcli device status

# Scan for networks
nmcli device wifi list
```

## If WiFi doesn't work after reboot
1. Check if conflicting modules need blacklisting:
   ```bash
   sudo tee /etc/modprobe.d/blacklist-broadcom.conf << 'EOF'
   blacklist b43
   blacklist b43legacy
   blacklist bcma
   blacklist ssb
   EOF
   ```

2. Load the wl module manually:
   ```bash
   sudo modprobe wl
   ```

3. Check for errors:
   ```bash
   dmesg | grep -i wl
   journalctl -b | grep -i wl
   ```

## To disable (if needed)
```bash
ujust configure-broadcom-wl disable
```
