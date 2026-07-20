{
  description = "Callum's NixOS configuration";

  inputs = {
    # Stable channel — most packages come from here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    # Unstable channel — used selectively (neovim, steam, proton, ghostty)
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Secure Boot (signs the boot chain; keys live in /var/lib/sbctl)
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, lanzaboote, ... }:
    let
      system = "x86_64-linux";

      # Exposes the unstable channel as `pkgs.unstable.<package>`
      unstableOverlay = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit (final) system;
          config.allowUnfree = true;
        };
      };
    in
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.overlays = [ unstableOverlay ]; }
          lanzaboote.nixosModules.lanzaboote
          ./hosts/desktop
        ];
      };
    };
}
