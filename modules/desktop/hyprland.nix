# Hyprland — appears as a session in GDM alongside GNOME.
# Window manager config itself lives in ~/.config/hypr/hyprland.conf.
{ pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # X11 apps (some games/launchers) still work
  };

  # The usual companion tools Hyprland doesn't ship itself
  environment.systemPackages = with pkgs; [
    waybar          # status bar
    wofi            # app launcher
    hyprpaper       # wallpaper
    hyprlock        # lock screen
    hypridle        # idle daemon
    mako            # notifications
    grim            # screenshots
    slurp           # region selection for screenshots
    wl-clipboard    # clipboard from the terminal
    brightnessctl
    pavucontrol     # audio mixer GUI
    networkmanagerapplet
  ];

  # Screen sharing / file pickers for wlroots compositors
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
