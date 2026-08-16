# KDE Plasma 6 on Wayland, with SDDM as the display manager.
#
# Debloated in three ways: Plasma's optional apps that duplicate something
# already in this config are dropped (see excludePackages), the two services
# plasma6 turns on by default that this machine has no use for (KDE PIM,
# Orca) are turned back off, and Baloo's file indexer is disabled so it
# doesn't chew disk I/O in the background while a game is running.
{ pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;

  # SDDM under Wayland (it uses kwin as the greeter compositor), so the
  # greeter and the session run on the same stack — no X server anywhere.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # plasma6 defaults both of these on. Akonadi/KDE PIM duplicates Thunderbird
  # (modules/dev), and Orca is a screen reader that would start every login.
  programs.kde-pim.enable = false;
  services.orca.enable = false;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    # konsole # ghostty is the terminal — see TerminalApplication below
    kate # neovim + zed cover editing
    ktexteditor # only there to give kate elevated-save actions
    elisa # music player
    khelpcenter
    krdp # remote desktop *server*
    plasma-browser-integration # browser<->Plasma widget we don't use
    plasma-workspace-wallpapers # ~400 MB of stock wallpapers
    aurorae # legacy (Plasma 5 era) window decoration engine
    kwin-x11 # Wayland-only session, so the X11 kwin is dead weight
    plasma-keyboard # on-screen touch keyboard — desktop has no touchscreen
    qtvirtualkeyboard # only pulled in for the plasma-keyboard KCM
    # Pulled in because services.fwupd is enabled, but Discover can't manage
    # a Nix system (no PackageKit backend) — it would only ever show firmware.
    discover
  ];

  # Baloo ships as a required part of Plasma, so it can't be excluded — but
  # it can be told not to index. /etc/xdg is the system default layer, so
  # anything set in System Settings later still wins.
  environment.etc."xdg/baloofilerc".text = ''
    [Basic Settings]
    Indexing-Enabled=false
  '';

  # Plasma's own "default applications" live in kdeglobals. TerminalService is
  # what Plasma 6 actually launches (Dolphin's "Open Terminal", Konsole-style
  # keyboard shortcuts); TerminalApplication is the older key some KDE apps
  # still read, so both are set.
  environment.etc."xdg/kdeglobals".text = ''
    [General]
    TerminalApplication=ghostty
    TerminalService=com.mitchellh.ghostty.desktop
  '';

  # The XDG half of the same thing: what non-KDE apps consult when they want
  # "the browser" or "a terminal". Written to /etc/xdg/mimeapps.list, which
  # ~/.config/mimeapps.list overrides if it's ever changed in System Settings.
  xdg.mime.defaultApplications = {
    "text/html" = "chromium-browser.desktop";
    "application/xhtml+xml" = "chromium-browser.desktop";
    "x-scheme-handler/http" = "chromium-browser.desktop";
    "x-scheme-handler/https" = "chromium-browser.desktop";
    "x-scheme-handler/about" = "chromium-browser.desktop";
    "x-scheme-handler/unknown" = "chromium-browser.desktop";
    "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
  };

  # And for anything that reads the environment instead of XDG (git, CLI
  # tools that shell out to $BROWSER, etc).
  environment.sessionVariables = {
    BROWSER = "chromium";
    TERMINAL = "ghostty";
  };
}
