# Host definition for the desktop PC (gaming + dev, dual boot with Windows)
{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/desktop
    ../../modules/networking
    ../../modules/gaming
    ../../modules/dev
    ../../modules/system/auto-update.nix
    ../../modules/system/config-repo.nix
    ../../modules/system/snapshots.nix
    ../../modules/system/secure-boot.nix
    ../../modules/system/fwupd.nix
    # Uncomment if this machine has an NVIDIA GPU:
    # ../../modules/hardware/nvidia.nix
  ];

  networking.hostName = "desktop";

  # Which session to boot into: "plasma", "gnome" or "hyprland".
  # (GNOME and Hyprland are both currently commented out in
  # modules/desktop/default.nix — re-enable the import there before
  # switching this to either of them.)
  my.desktop.session = "plasma";

  # Console emulators (PS1/PS2/PS3, Xbox, GameCube, Wii). PS1/PS2/GameCube/Wii
  # run as RetroArch cores (see modules/gaming/retro.nix); PS3 and Xbox are
  # standalone since no libretro core exists for them.
  my.gaming.retro.enable = true;

  system.stateVersion = "26.05"; # never change this after install
}
