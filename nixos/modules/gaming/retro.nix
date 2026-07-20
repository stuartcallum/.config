# Retro / console emulation — disabled by default.
# Flip on with `my.gaming.retro.enable = true;` in the host config.
#
# ROMs live in ~/Games/roms/<console>; BIOS/firmware dumps go in
# ~/Games/roms/bios (PS1 and PS2 need BIOS files; RPCS3 needs the official
# PS3 firmware PUP, installed via File > Install Firmware).
#
# Controllers: the DualSense (PS5) works out of the box via the kernel's
# hid-playstation driver, and the Steam udev rules (already enabled by the
# gaming module) grant device access. joycond handles Switch Pro Controller
# pairing.
{ config, lib, pkgs, ... }:

{
  options.my.gaming.retro.enable =
    lib.mkEnableOption "retro console emulators (PS1/PS2/PS3, Xbox, GameCube, Wii)";

  config = lib.mkIf config.my.gaming.retro.enable {
    environment.systemPackages = with pkgs; [
      duckstation  # PS1
      pcsx2        # PS2
      xemu         # original Xbox
      rpcs3        # PS3
      dolphin-emu  # GameCube + Wii
    ];

    # Switch Pro Controller pairing daemon
    services.joycond.enable = true;

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
