# Secure Boot via lanzaboote — signs systemd-boot, kernels, and initrds
# with our own keys so the machine boots with Secure Boot enabled.
#
# One-time setup (already done if the machine boots with SB on):
#   1. sudo sbctl create-keys
#   2. rebuild (nrs) — lanzaboote signs everything
#   3. sudo sbctl verify         # every file should say "signed"
#   4. reboot -> BIOS -> Secure Boot -> clear keys / enter Setup Mode
#   5. sudo sbctl enroll-keys --microsoft   # --microsoft keeps Windows + GPU
#   6. reboot -> BIOS -> enable Secure Boot
#   7. bootctl status            # "Secure Boot: enabled"
{ lib, pkgs, ... }:

{
  # lanzaboote replaces the systemd-boot module (same menu, same entries)
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    configurationLimit = 15;
  };

  environment.systemPackages = [ pkgs.sbctl ];
}
