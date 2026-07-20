# Gaming — Steam and Proton track unstable for the newest compatibility work
{ pkgs, ... }:

{
  imports = [ ./retro.nix ];

  # Swap the stable steam packages for unstable ones. Overlaying (rather than
  # setting programs.steam.package directly) keeps the module's FHS-env and
  # compat-path wiring intact.
  nixpkgs.overlays = [
    (final: prev: {
      steam = prev.unstable.steam;
      steam-unwrapped = prev.unstable.steam-unwrapped;
    })
  ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    # GloriousEggroll's Proton build (unstable) — shows up in Steam under
    # Settings > Compatibility as "Proton-GE"
    extraCompatPackages = [ pkgs.unstable.proton-ge-bin ];
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
