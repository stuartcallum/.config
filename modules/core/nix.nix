# Nix daemon settings — flakes, garbage collection, store optimisation
{ ... }:

{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      # Members of wheel can use extra nix features and substituters
      trusted-users = [ "root" "@wheel" ];
      auto-optimise-store = true;
    };

    # Weekly garbage collection so old generations don't eat the disk.
    # Generations newer than 14 days are kept, so rollback stays possible.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Steam, firmware blobs, etc. are unfree
  nixpkgs.config.allowUnfree = true;
}
