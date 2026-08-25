# Terrene

## Purpose

My personal daily drive utilizing the Fedora Cosmic container image (quay.io/fedora-ostree-desktops/cosmic-atomic:44) featuring the Cosmic Desktop. This setup includes development tools, including packages for Rust, C, Go, and Zig, as well as the Helix, Neovim, and Emacs editor for efficient writing. Furthermore, YubiKey authentication are enabled for sudo access, providing an additional layer of protection.
## Install

### bootc switch
Rebase from bootc
```bash
sudo bootc switch ghcr.io/yardquit/terrene:latest
```

Restart your system for the changes take effect:
```bash
systemctl reboot
```

### YubiKey
Instructions to complete the yubikey registration process.
```bash
# Insert your YubiKey into a compatible USB port on your computer.
ykpamcfg -2
```
Ensure that YubiKey support is enabled and functional in your system settings.
```bash
sudo echo "Testing sudo with YubiKey"
```
