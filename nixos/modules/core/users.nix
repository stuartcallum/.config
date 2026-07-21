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

  # `nru` — push the config, snapshot, pull the latest flake inputs, rebuild.
  # git push runs as callum (needs your SSH key); the snapshot and rebuild
  # need root, which passwordless wheel sudo above already covers.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nru" ''
      set -e
      cd /home/callum/.config

      echo "==> Pushing config to git..."
      git push

      echo "==> Taking a btrfs snapshot..."
      sudo nix-snapshot

      echo "==> Updating flake inputs..."
      cd nixos
      nix flake update

      echo "==> Rebuilding..."
      sudo nixos-rebuild switch --flake .#desktop

      if ! git diff --quiet -- flake.lock; then
        echo "Note: flake.lock changed — commit and push it when convenient."
      fi
    '')
  ];

  # Keep /etc/nixos pointing at the real config in callum's home directory,
  # so standard tooling finds it and callum can edit/commit without sudo.
  systemd.tmpfiles.rules = [
    "L+ /etc/nixos - - - - /home/callum/.config/nixos"
  ];
}
