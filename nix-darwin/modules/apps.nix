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
		_1password-cli
		docker
		colima
		zsh-autocomplete
		zsh-autosuggestions
		oh-my-zsh
		pssh
		p7zip
		bun
		ffmpeg
		btop
		htop
		kubectl
		rancher
		tree
		openjdk
		openvpn
		rancher
	];

	homebrew = {
		enable = true;	
		casks = [
			"wezterm"
			"macfuse"
			"google-chrome"
			"spotify"
			"obsidian"
			"1password"
			"visual-studio-code"
			"pgadmin4"
			"dbgate"
			"zed"
			"vlc"
			"openvpn-connect"
			"openwebstart"
#			"nikitabobko/tap/areospace"
		];
		onActivation = {
			autoUpdate = true;
			cleanup = "uninstall";
			upgrade = true;
		};
	};
}
