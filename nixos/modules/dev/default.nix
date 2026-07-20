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

    # Browsers
    firefox
    chromium

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
