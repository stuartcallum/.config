# User accounts and sudo policy
{ pkgs, ... }:

{
  users.users.callum = {
    isNormalUser = true;
    description = "Callum";
    extraGroups = [
      "wheel"          # sudo
      "networkmanager" # manage wifi without sudo
      "video"
      "audio"
    ];
    shell = pkgs.zsh;
    # Set a real password with `passwd` after first boot.
    # (Login is automatic — see modules/desktop — but sudo and the lock
    # screen still want a password.)
    initialPassword = "changeme";
  };

  programs.zsh.enable = true;

  # Passwordless sudo for the wheel group (single-user desktop)
  security.sudo.wheelNeedsPassword = false;

  # Convenience: `nrs` rebuilds from the config repo in ~/.config
  environment.shellAliases = {
    nrs = "sudo nixos-rebuild switch --flake /home/callum/.config/nixos#desktop";
    nrb = "sudo nixos-rebuild boot --flake /home/callum/.config/nixos#desktop";
  };

  # Keep /etc/nixos pointing at the real config in callum's home directory,
  # so standard tooling finds it and callum can edit/commit without sudo.
  systemd.tmpfiles.rules = [
    "L+ /etc/nixos - - - - /home/callum/.config/nixos"
  ];
}
