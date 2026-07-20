# NixOS config — desktop

Flake-based NixOS configuration for the desktop PC. Gaming + dev work,
GNOME/Hyprland, dual boot with Windows.

Lives in the `nixos/` subdirectory of
[stuartcallum/.config](https://github.com/stuartcallum/.config), which is
cloned as `~/.config` on the machine — so the same repo carries the system
config and the dotfiles (`hypr/`, `nvim/`, `ghostty/`, `zsh/`, ...) that go
with it.

## Layout (of this subdirectory)

```
flake.nix                    # inputs: nixos-25.05 (stable) + unstable overlay
hosts/desktop/               # host entry point + hardware-configuration.nix
modules/
  core/                      # boot loader, nix settings, users/sudo, locale
  desktop/                   # GNOME, Hyprland, autologin toggle, pipewire
  networking/                # wifi (NetworkManager + firmware), OpenVPN
  gaming/                    # steam/proton-GE (unstable), gamemode, gamescope
  dev/                       # neovim/ghostty (unstable), browsers, ssh, docker
  system/auto-update.nix     # nightly upgrades
  hardware/nvidia.nix        # opt-in, import from the host if needed
secrets/                     # gitignored — OpenVPN profile lives here
```

> **The repo is public.** `secrets/` (the OpenVPN profile with its inline
> private key) is gitignored and must be moved between machines by hand —
> a fresh clone will NOT contain it.

Most packages come from **nixos-25.05**. Neovim, Steam, Proton-GE, and
Ghostty come from **nixos-unstable** via the `pkgs.unstable` overlay.

## Installing (dual boot with Windows)

### 0. Before leaving Windows

- **Disable Fast Startup** (Control Panel → Power Options), otherwise Windows
  half-hibernates and the NTFS partition can't be touched safely.
- In Disk Management, **shrink the Windows partition** to free space for Linux.
- Note your EFI System Partition size. Windows usually makes it ~100 MB, which
  works but only fits a few NixOS generations (the config caps it at 5). If
  you want headroom, this is the moment to recreate the ESP at 1 GB — but
  resizing an ESP in place is fiddly; living with the 100 MB one is fine.

### 1. Boot the NixOS ISO and partition

Boot the graphical ISO but do the install from a terminal. **Do not touch the
Windows or EFI partitions when creating** — only create one new partition in
the freed space (this example assumes `nvme0n1p1` is the existing EFI
partition and `p5` is the new Linux one; check with `lsblk`):

```sh
sudo -i
parted /dev/nvme0n1 -- mkpart root btrfs <start> 100%

# Btrfs with subvolumes
mkfs.btrfs -L nixos /dev/nvme0n1p5
mount /dev/nvme0n1p5 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt

mount -o subvol=@,compress=zstd,noatime /dev/nvme0n1p5 /mnt
mkdir -p /mnt/{home,nix,boot}
mount -o subvol=@home,compress=zstd,noatime /dev/nvme0n1p5 /mnt/home
mount -o subvol=@nix,compress=zstd,noatime /dev/nvme0n1p5 /mnt/nix

# Mount the EXISTING Windows EFI partition — do not format it!
mount /dev/nvme0n1p1 /mnt/boot
```

No swap partition here — add one (or use zram) if you want hibernation or
have <16 GB RAM.

### 2. Generate hardware config and bring in this repo

```sh
nixos-generate-config --root /mnt

# The NIXDATA USB stick carries the whole repo — git history, dotfiles, and
# the (gitignored) VPN profile. Plug it in and copy it as ~/.config:
mkdir -p /usb
mount /dev/disk/by-label/NIXDATA /usb
cp -r /usb/config /mnt/home/callum/.config
umount /usb

# FAT32 doesn't store file modes, so tell git to ignore them
git -C /mnt/home/callum/.config config core.filemode false

cp /mnt/etc/nixos/hardware-configuration.nix \
   /mnt/home/callum/.config/nixos/hosts/desktop/

# (No USB handy? `git clone https://github.com/stuartcallum/.config` works
# too — but then copy secrets/house.ovpn across separately; it's not in git.)
```

Check the generated file lists the three btrfs subvolumes and the `/boot`
vfat mount. Add `"compress=zstd" "noatime"` to each btrfs `options` list if
they aren't there.

If the machine has an NVIDIA GPU, uncomment the nvidia import in
`hosts/desktop/default.nix`.

Flakes only see **git-tracked** files, so commit the hardware config:

```sh
cd /mnt/home/callum/.config
git add -A && git commit -m "Add desktop hardware configuration"
```

### 3. Install

```sh
nixos-install --flake /mnt/home/callum/.config/nixos#desktop
reboot
```

### 4. First boot

You'll be logged straight into GNOME (autologin). Then:

```sh
passwd                      # replace the placeholder password 'changeme'
sudo chown -R callum:users ~/.config
```

Windows should appear as an entry in the systemd-boot menu automatically. If
the clocks disagree between OSes, that's already handled
(`hardwareClockInLocalTime`).

## Day-to-day

| Task | Command |
|------|---------|
| Rebuild after editing config | `nrs` (alias, no sudo password needed) |
| Rebuild for next boot only | `nrb` |
| Switch GNOME ↔ Hyprland | edit `my.desktop.session` in `hosts/desktop/default.nix`, then `nrs` |
| Update pinned inputs | `nix flake update && nrs`, commit `flake.lock` |
| Start/stop the VPN | `sudo systemctl start openvpn-house` / `stop` |
| Roll back | pick an older generation in the boot menu |

The config lives at `~/.config/nixos`, owned by you — edit and `git push`
without sudo. `/etc/nixos` is a symlink to it.

Auto-updates run nightly at ~04:00 against the latest channel commits and
activate on the **next boot**; they never touch `flake.lock` or reboot the
machine themselves.

## Notes

- **Passwordless login** = GDM autologin. Your account still has a password
  (for sudo, ssh, and the lock screen) — set it on first boot.
- **Sudo**: `nixos-rebuild` is passwordless for callum; everything else
  prompts normally.
- **Hyprland**'s window manager config comes from the repo's own `hypr/`
  directory, which lands at `~/.config/hypr/` with the clone — nothing extra
  to set up.
- **VPN**: `sudo systemctl start openvpn-house`. If OpenVPN 2.6 rejects the
  router's legacy cipher, append `data-ciphers-fallback AES-128-CBC` to
  `secrets/house.ovpn`.
- **Proton-GE** appears in Steam under Settings → Compatibility once you
  enable "Steam Play for all other titles".
