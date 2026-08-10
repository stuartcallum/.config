# Zsh: oh-my-zsh with a minimal prompt, fzf-powered history/file search.
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.fzf ];

  environment.shellAliases = {
    vi = "nvim";
    vim = "nvim";
    ll = "ls -lah";
    history = "history 1";
  };

  programs.zsh = {
    enable = true;
    histSize = 10000;
    ohMyZsh = {
      enable = true;
      theme = "minimal";
      plugins = [ "git" "fzf" ];
    };
  };
}
