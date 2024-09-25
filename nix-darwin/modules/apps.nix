{ pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		neovim
		fzf
		google-cloud-sdk
		watch
		ext4fuse
		starship
		zsh-autosuggestions
		zsh-syntax-highlighting
		_1password
#		zulu8
	];

	homebrew = {
		enable = true;	
		casks = [
			"wezterm"
			"macfuse"
			"google-chrome"
			"spotify"
			"openvpn-connect"
			"obsidian"
			"1password"
			"OpenWebStart"
		];
	};
}
