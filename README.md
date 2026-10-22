# Terrene

## Purpose

My personal daily drive utilizing the Fedora Cosmic container image (quay.io/fedora-ostree-desktops/cosmic-atomic:44) featuring the Cosmic Desktop. This setup includes development tools, including packages for Rust, C, Go, and Zig, as well as the Helix, Neovim, and Emacs editor for efficient writing. Furthermore, YubiKey authentication are enabled for sudo access, providing an additional layer of protection.
## Colours

The [Ao](https://github.com/YardQuit/ao) palette is the default look throughout: the COSMIC desktop (dark, with the ao-light theme for light mode), Emacs, Helix, Neovim and the kitty, Alacritty, foot and Ptyxis terminals. These are defaults only - anything set in your own `~/.config` takes precedence.

## Framework Laptop 13

Set up for the Framework Laptop 13 by default: fingerprint login and unlock at the COSMIC login and lock screens (sudo still takes the YubiKey and your password), power profiles in the COSMIC battery applet, firmware updates from the LVFS, and staying awake with the lid closed while docked or on mains power. If the installer ran in basic graphics mode and left `nomodeset` on the kernel command line, the first boot removes it and the next reboot comes up on the real graphics driver. A battery charge limit at 80% is in `build_files/build.sh`, switched off.

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
