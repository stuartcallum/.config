{ pkgs, ... }: {
	environment.systemPackages = with pkgs; [
		neovim
		fzf
		google-cloud-sdk
		watch
		ext4fuse
		starship
		_1password-cli
		docker
		colima
		pssh
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
			"nikitabobko/tap/aerospace"
		];
		onActivation = {
			autoUpdate = true;
			cleanup = "uninstall";
			upgrade = true;
		};
	};
}
