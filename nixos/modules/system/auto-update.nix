# Automatic system updates.
#
# Nightly at 04:00 the system pulls the latest nixpkgs (stable + unstable),
# rebuilds, and activates. The flake.lock on disk is NOT modified
# (--no-write-lock-file), so the repo stays clean and owned by callum;
# run `nix flake update && git commit flake.lock` yourself when you want
# to pin what the auto-updater has been building.
{ ... }:

{
  system.autoUpgrade = {
    enable = true;
    # ~/.config is a clone of github.com/stuartcallum/.config; the flake lives
    # in its nixos/ subdirectory. To have the machine track GitHub directly
    # instead of the local checkout, use:
    #   flake = "github:stuartcallum/.config?dir=nixos#desktop";
    flake = "/home/callum/.config/nixos#desktop";
    flags = [
      "--update-input" "nixpkgs"
      "--update-input" "nixpkgs-unstable"
      "--no-write-lock-file"
      "-L"
    ];
    dates = "04:00";
    randomizedDelaySec = "45min";
    # Activate on next boot instead of live-switching under you.
    # Set to false if you'd rather updates apply immediately.
    operation = "boot";
    # Never reboot the machine on its own
    allowReboot = false;
  };
}
