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
    # Uncomment if this machine has an NVIDIA GPU:
    # ../../modules/hardware/nvidia.nix
  ];

  networking.hostName = "desktop";

  # Which session to boot into: "gnome" or "hyprland".
  # (Hyprland is currently commented out in modules/desktop/default.nix —
  # re-enable it there before switching this to "hyprland".)
  my.desktop.session = "gnome";

  system.stateVersion = "26.05"; # never change this after install
}
