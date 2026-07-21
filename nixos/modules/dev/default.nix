# Dev tooling — editors, terminals, browsers, ssh, containers.
# Neovim and Ghostty track unstable; everything else is stable.
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.unstable.neovim-unwrapped;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # SSH: server on, key-based auth only
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # direnv + nix-direnv: per-project dev shells that load on `cd`
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Containers for dev work
  virtualisation.docker.enable = true;
  users.users.callum.extraGroups = [ "docker" ];

  environment.systemPackages = with pkgs; [
    # Terminal (unstable)
    unstable.ghostty

    # Editors / AI tooling (unstable)
    unstable.claude-code # installs the `claude` CLI
    unstable.zed-editor

    # Browsers / mail
    firefox
    chromium
    thunderbird

    # iCloud Mail as a standalone app window (Chromium's --app mode) rather
    # than a browser tab — shows up in the app grid as "iCloud Mail".
    (pkgs.makeDesktopItem {
      name = "icloud-mail";
      desktopName = "iCloud Mail";
      genericName = "Webmail";
      icon = "mail-client";
      exec = "${pkgs.chromium}/bin/chromium --app=https://www.icloud.com/mail";
      categories = [ "Network" "Email" ];
    })

    # VCS
    git
    gh

    # CLI staples
    ripgrep
    fd
    jq
    tree
    wget
    curl
    htop
    unzip

    # Build basics for the odd native dependency
    gcc
    gnumake
    pkg-config
  ];
}
