{ pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		neovim
		fzf
		google-cloud-sdk
		jre
		watch
		ext4fuse
	];

	homebrew = {
		enable = true;	
		casks = [
			"wezterm"
			"macfuse"
		];
	};
}
