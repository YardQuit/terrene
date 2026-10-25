# Terrene

## Purpose

My personal daily drive utilizing the Fedora Cosmic container image (quay.io/fedora-ostree-desktops/cosmic-atomic:45) featuring the Cosmic Desktop. This setup includes development tools, including packages for Rust, C, Go, and Zig, as well as the Helix, Neovim, and Emacs editor for efficient writing. Signing in - at the login and lock screens, for sudo and in password dialogs - takes a YubiKey touch, a fingerprint or the password.
## Colours

The [Ao](https://github.com/YardQuit/ao) palette is the default look throughout: the COSMIC desktop (dark, with the ao-light theme for light mode), Emacs, Helix, Neovim and the kitty, Alacritty, foot and Ptyxis terminals. These are defaults only - anything set in your own `~/.config` takes precedence.

## Framework Laptop 13

Set up for the Framework Laptop 13 by default: a YubiKey touch, a fingerprint or the password wherever you sign in, with the fingerprint skipped while the lid is closed (the reader sits under it), power profiles in the COSMIC battery applet, firmware updates from the LVFS, and staying awake with the lid closed while docked or on mains power. Docked with the lid closed, a keypress on the USB keyboard (Kinesis Advantage360 Pro) or a click on the trackball (Kensington Expert Wireless) wakes it from suspend; the rule is `/usr/lib/udev/rules.d/90-terrene-usb-wakeup.rules`, and it also lets plugging or unplugging something on the dock wake it. If the installer ran in basic graphics mode and left `nomodeset` on the kernel command line, the first boot removes it and the next reboot comes up on the real graphics driver. A battery charge limit at 80% is in `build_files/build.sh`, switched off.

COSMIC keeps one display layout per set of connected screens, in `~/.local/state/cosmic-comp/outputs.ron`, and the login screen uses the same layouts. New accounts start with the Samsung LC49G95T at its native 5120×1440 at 120 Hz, both on its own with the lid closed and beside the laptop screen with the lid open (`/etc/skel/.local/state/cosmic-comp/outputs.ron`). If it still comes up at a lower resolution, set its native mode in Settings → Displays with the lid as it was when the problem showed: the Samsung on its own is a layout of its own, so fixing it with the lid open leaves the lid-closed layout - and the login screen - as they were. Don't edit `outputs.ron` by hand while COSMIC is running - it is written back at logout.

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

### Signing in
Wherever you sign in - the login and lock screens, sudo, password dialogs - the system asks in this order and the first that succeeds is enough:

1. a YubiKey: touch it when asked ("Please touch the device")
2. a fingerprint, skipped while the lid is closed
3. the password

Register your YubiKey with the origin `pam://terrene`, the same on every machine running this image. With the first key inserted:
```bash
mkdir -p ~/.config/Yubico
pamu2fcfg -o pam://terrene -i pam://terrene > ~/.config/Yubico/u2f_keys
```
Then for each further key, one at a time:
```bash
pamu2fcfg -n -o pam://terrene -i pam://terrene >> ~/.config/Yubico/u2f_keys
```
Keys whose firmware only has FIDO2 ask for their PIN while registering, not when you sign in. Enrol fingers in COSMIC's settings or with `fprintd-enroll`. Test in a terminal, with the lid open and then closed:
```bash
sudo -k; sudo true
```
Keep a second terminal with `sudo -i` open until the key, the finger and the password all work.
