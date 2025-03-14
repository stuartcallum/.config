{ pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		neovim
		fzf
		google-cloud-sdk
		watch
		ext4fuse
		_1password-cli
		oh-my-zsh
		docker
		pssh
		colima
		p7zip
		bun
		ffmpeg
		btop
		htop
		kubectl
		rancher
		tree
		openvpn
		rancher
		wget
		victor-mono
		k9s
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
			"vlc"
			"openvpn-connect"
			"openwebstart"
			"nikitabobko/tap/aerospace"
			"notion"
			"ghostty@tip"
			"iina"
		];
		onActivation = {
			autoUpdate = true;
			cleanup = "uninstall";
			upgrade = true;
		};
	};
}
