# Retro / console emulation — disabled by default.
# Flip on with `my.gaming.retro.enable = true;` in the host config.
#
# PS1, PS2, GameCube and Wii are managed as RetroArch cores: launch
# RetroArch, "Load Core" (or a core's already-loaded content) to pick which
# system to play. PS3 and original Xbox have no libretro cores, so RPCS3 and
# xemu are kept as their own standalone launchers instead.
#
# ROMs live in ~/Games/roms/<console>; BIOS/firmware dumps go in
# ~/Games/roms/bios (PS1 and PS2 cores need BIOS files, set in RetroArch's
# Core Options; RPCS3 needs the official PS3 firmware PUP, installed via
# File > Install Firmware).
#
# Controller: the DualSense (PS5) works out of the box via the kernel's
# hid-playstation driver, and the Steam udev rules (already enabled by the
# gaming module) grant device access.
{ config, lib, pkgs, ... }:

{
  options.my.gaming.retro.enable =
    lib.mkEnableOption "retro console emulators (PS1/PS2/PS3, Xbox, GameCube, Wii)";

  config = lib.mkIf config.my.gaming.retro.enable {
    # (these resolve to unstable via the overlay in ./default.nix)
    environment.systemPackages = with pkgs; [
      xemu  # original Xbox — no libretro core, launched standalone
      rpcs3 # PS3 — no libretro core, launched standalone
      pcsx2 # PS2
      dolphin-emu # Gamecube, Wii
      eden # Switch
      nzbget # Download games
    ];

    # ROM library skeleton, owned by callum
    systemd.tmpfiles.rules = [
      "d /home/callum/Games                0755 callum users -"
      "d /home/callum/Games/roms           0755 callum users -"
      "d /home/callum/Games/roms/ps1       0755 callum users -"
      "d /home/callum/Games/roms/ps2       0755 callum users -"
      "d /home/callum/Games/roms/ps3       0755 callum users -"
      "d /home/callum/Games/roms/xbox      0755 callum users -"
      "d /home/callum/Games/roms/gamecube  0755 callum users -"
      "d /home/callum/Games/roms/wii       0755 callum users -"
      "d /home/callum/Games/roms/bios      0755 callum users -"
    ];
  };
}
