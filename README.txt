# ARCH SETUP

---

This is a simple shell script to setup any new machine to my specs.

This uses my personal dotfiles: https://github.com/itsjustgalileo/dotfiles.

---

This assumes you have already installed Arch Linux x86_64:https://archlinux.org/download/ (See Arch install guide: https://wiki.archlinux.org/title/Installation_guide for more):
- linux (required)
- linux-firmware (required)
- base (required)
- base-devel (required)
- networkmanager (required)
- sof-firmware (required if new soundcard)
- grub (or any bootloader)
- efibootmgr (or any boot manager)
- zsh (bash would do it too)
- vi (or any text editor)
- man-db (optional)
- man-pages (optional)

*Instructions*

```
# After installing linux, connect to internet and run: (enter sudo password whenever prompted)
curl -o ~/setup.sh https://raw.githubusercontent.com/itsjustgalileo/Arch-setup/master/setup.sh
chmod +x ~/setup.sh
~/setup.sh
```

From here on, the system should be pretty well setup
