# Gaming — the whole section tracks unstable for the newest compatibility work
{ lib, pkgs, ... }:

{
  imports = [
    ./retro.nix
    ./optimizations.nix
  ];

  # Every package named here resolves to its unstable build, everywhere —
  # including inside NixOS modules (programs.steam, programs.gamemode, ...).
  # To put a gaming package on unstable, add its name to this list; the rest
  # of the gaming modules just use plain `pkgs.<name>`.
  # (`final.unstable`, not `prev.` — overlay merge order across modules is
  # unspecified, and only the fixed point is guaranteed to have `unstable`.)
  nixpkgs.overlays = [
    (final: prev: lib.genAttrs [
      "steam"
      "steam-unwrapped"
      "proton-ge-bin"
      "gamemode"
      "gamescope"
      "xemu"
      "rpcs3"
      "pactl"
    ] (name: final.unstable.${name}))
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    # GloriousEggroll's Proton build — shows up in Steam under
    # Settings > Compatibility as "Proton-GE"
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries your binary needs here
    stdenv.cc.cc.lib 
  ];

  # `gamemoderun %command%` in a game's launch options gets CPU governor
  # boosts and priority tweaks while the game runs
  programs.gamemode.enable = true;
  programs.gamemode.settings = {
    # GameMode's GPU tuning is opt-in — without this it only touches CPU
    # governor/nice/ioprio and leaves the GPU clocked as normal.
    gpu = {
      apply_gpu_optimisations = "accept-responsibility";
      gpu_device = 0;
      amd_performance_level = "high";
    };
  };

  # Valve's micro-compositor: resolution scaling / frame limiting per game
  programs.gamescope.enable = true;

  # No swap was configured at all (hardware-configuration.nix has
  # swapDevices = [ ];) — zram gives cheap compressed RAM-backed swap so
  # shader-compilation spikes and texture streaming don't risk an OOM kill
  # mid-game.
  zramSwap.enable = true;

  # 32-bit graphics libraries — required by Steam and many Proton games.
  #
  # Mesa itself is pinned to unstable here (not via the name-list overlay
  # above, since this is a system-wide driver package, not an app) to get
  # RDNA3/GFX11 FSR 4 support as it lands in RADV — see FSR_4.md.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    package = pkgs.unstable.mesa;
    package32 = pkgs.unstable.pkgsi686Linux.mesa;
  };

  environment.systemPackages = with pkgs; [
    mangohud # FPS/frametime overlay: `mangohud %command%`

    # Opt-in experimental native-Wayland Steam client, kept separate from
    # the normal `steam` launcher — Valve's own issue tracker has open
    # reports of games failing to launch in this mode as of March 2026.
    # If a game won't start, quit this and use the regular Steam icon.
    #
    # Also exports Wayland hints for anything launched *from* this Steam
    # instance: SDL_VIDEODRIVER=wayland picks up native-Wayland SDL2 games
    # (other engines need their own per-game flag — there's no universal
    # switch), and PROTON_ENABLE_WAYLAND=1 makes Proton/Proton-GE use Wine's
    # Wayland driver instead of XWayland. Both are inherited by child
    # processes, so games still choose whether to honour them — same
    # fall-back-to-the-regular-icon caveat as above if one breaks.
    (pkgs.writeShellScriptBin "steam-wayland" ''
      export SDL_VIDEODRIVER=wayland
      export PROTON_ENABLE_WAYLAND=1
      exec ${pkgs.steam}/bin/steam --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"
    '')

    # .desktop entry so steam-wayland shows up in the desktop's app launcher
    # (a writeShellScriptBin alone only adds a $PATH binary, no launcher
    # icon). Reuses Steam's own icon and MIME handlers so it's a drop-in
    # replacement for the regular Steam tile.
    (pkgs.makeDesktopItem {
      name = "steam-wayland";
      desktopName = "Steam (Wayland)";
      comment = "Play games on Steam, using the native Wayland client";
      exec = "steam-wayland %U";
      icon = "steam";
      categories = [ "Network" "FileTransfer" "Game" ];
      mimeTypes = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
    })
  ];
}
