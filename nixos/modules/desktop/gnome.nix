# GNOME desktop with GDM as the display manager for both sessions
{ pkgs, ... }:

{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Trim GNOME's default app bloat
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-music
    epiphany # GNOME's browser — we use firefox/chromium
    geary
    gnome-maps
    gnome-contacts
  ];

  environment.systemPackages = with pkgs; [
    gnome-tweaks
  ];
}
