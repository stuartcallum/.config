# Desktop environments — GNOME and Hyprland are both installed;
# `my.desktop.session` picks which one auto-login lands in.
{ config, lib, ... }:

{
  imports = [
    ./gnome.nix
    # ./hyprland.nix  # disabled for now — uncomment (and set
    #                 # my.desktop.session = "hyprland" if desired) to re-enable
    ./audio.nix
  ];

  options.my.desktop.session = lib.mkOption {
    type = lib.types.enum [ "gnome" "hyprland" ];
    default = "gnome";
    description = "Session to log into automatically. Set per-host and rebuild to toggle.";
  };

  config = {
    # Passwordless login: GDM logs callum straight in, no password prompt.
    services.displayManager = {
      autoLogin = {
        enable = true;
        user = "callum";
      };
      defaultSession = config.my.desktop.session;
    };

    # Workaround for the well-known GDM autologin race on tty1
    # (https://github.com/NixOS/nixpkgs/issues/103746)
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;
  };
}
