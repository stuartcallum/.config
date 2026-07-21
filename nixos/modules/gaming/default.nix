# Gaming — the whole section tracks unstable for the newest compatibility work
{ lib, pkgs, ... }:

{
  imports = [ ./retro.nix ];

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
      "mangohud"
      "duckstation"
      "pcsx2"
      "xemu"
      "rpcs3"
      "dolphin-emu"
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

  # `gamemoderun %command%` in a game's launch options gets CPU governor
  # boosts and priority tweaks while the game runs
  programs.gamemode.enable = true;

  # Valve's micro-compositor: resolution scaling / frame limiting per game
  programs.gamescope.enable = true;

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
    (pkgs.writeShellScriptBin "steam-wayland" ''
      exec ${pkgs.steam}/bin/steam --enable-features=UseOzonePlatform --ozone-platform=wayland "$@"
    '')
  ];
}
