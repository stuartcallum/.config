# Desktop environments — KDE Plasma is the session this machine boots into;
# `my.desktop.session` picks which one auto-login lands in.
{ config, lib, ... }:

{
  imports = [
    ./kde.nix
    # ./gnome.nix   # replaced by KDE Plasma — uncomment (and set
    #               # my.desktop.session = "gnome") to go back to GNOME
    # ./hyprland.nix  # disabled for now — uncomment (and set
    #                 # my.desktop.session = "hyprland" if desired) to re-enable
    ./audio.nix
    ./fonts.nix
    ./keyd.nix
  ];

  options.my.desktop.session = lib.mkOption {
    type = lib.types.enum [ "plasma" "gnome" "hyprland" ];
    default = "plasma";
    description = "Session to log into automatically. Set per-host and rebuild to toggle.";
  };

  config = {
    # Passwordless login: the display manager logs callum straight in, no
    # password prompt. (SDDM under KDE, GDM under GNOME.)
    services.displayManager = {
      autoLogin = {
        enable = true;
        user = "callum";
      };
      defaultSession = config.my.desktop.session;
    };

    # Workaround for the well-known GDM autologin race on tty1
    # (https://github.com/NixOS/nixpkgs/issues/103746). SDDM doesn't have it,
    # so under KDE we keep tty1 as a fallback console instead.
    systemd.services."getty@tty1".enable =
      lib.mkIf (config.my.desktop.session == "gnome") false;
    systemd.services."autovt@tty1".enable =
      lib.mkIf (config.my.desktop.session == "gnome") false;
  };
}
