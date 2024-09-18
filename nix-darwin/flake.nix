{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, home-manager, ... }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs {
      system = system;
    };

    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
	  pkgs.neovim
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
#      nixpkgs.hostPlatform = "aarch64-darwin";

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."Callums-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      system = system;
      modules = [
	configuration
	home-manager.darwinModules.home-manager
	nix-homebrew.darwinModules.nix-homebrew
        {
	    nix-homebrew = {
	    enable = true;
	    user = "callum";
	    taps = {
	      "homebrew/homebrew-core" = homebrew-core;
	      "homebrew/homebrew-cask" = homebrew-cask;
	      "homebrew/homebrew-bundle" = homebrew-bundle;
	    };
	    mutableTaps = false;
	    autoMigrate = true;
#	    onActivation = {
#	    	autoUpdate = true;
#		cleanup = "uninstall";
#		upgrade = true;
#	    };
	};
	}
	{
	  services.nix-daemon.enable = true;
	}
#	home-manager.darwinModules.home-manager {
#		home-manager.useGlobalPkgs = true;
#		home-manager.useUserPackages = true;
#		home-manager.users.callum = import ./home.nix;
#	}
	./modules/apps.nix
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Callums-MacBook-Pro".pkgs;

  };
}
