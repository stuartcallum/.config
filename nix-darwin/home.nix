# config for home manager

{ config, pkgs, ... }:

{
	home.username = "callum";
	home.homeDirectory = "/Users/callum";
	

	home.packages = [
	];

	home.file = {
		".config/nvim".source = "./nvim";
	};

	system.stateVersion = 5;
}
