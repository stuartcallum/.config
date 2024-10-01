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
		docker
		colima
		zsh-autocomplete
		zsh-autosuggestions
		oh-my-zsh
		pssh
		p7zip
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
			"visual-studio-code"
			"zed"
		];
	};
}
