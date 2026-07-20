# Gaming — the whole section tracks unstable for the newest compatibility work
{ lib, pkgs, ... }:

{
  imports = [ ./retro.nix ];

  # Every package named here resolves to its unstable build, everywhere —
  # including inside NixOS modules (programs.steam, programs.gamemode, ...).
  # To put a gaming package on unstable, add its name to this list; the rest
  # of the gaming modules just use plain `pkgs.<name>`.
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
    ] (name: prev.unstable.${name}))
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

  # 32-bit graphics libraries — required by Steam and many Proton games
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  environment.systemPackages = with pkgs; [
    mangohud # FPS/frametime overlay: `mangohud %command%`
  ];
}
