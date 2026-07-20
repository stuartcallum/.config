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
    # Uncomment if this machine has an NVIDIA GPU:
    # ../../modules/hardware/nvidia.nix
  ];

  networking.hostName = "desktop";

  # Which session to boot into: "gnome" or "hyprland".
  # Both are always installed — change this and rebuild to switch.
  my.desktop.session = "gnome";

  system.stateVersion = "25.05"; # never change this after install
}
