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

  # Passwordless sudo for the wheel group (single-user desktop)
  security.sudo.wheelNeedsPassword = false;

  # `nrs`/`nrb` — update flake inputs, then rebuild (switch/boot). `nix flake
  # update` runs as callum (writes flake.lock in the repo); the rebuild needs
  # root, which passwordless wheel sudo above already covers.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nrs" ''
      set -e
      cd /home/callum/.config/nixos

      echo "==> Updating flake inputs..."
      nix flake update

      echo "==> Rebuilding (switch)..."
      sudo nixos-rebuild switch --flake .#desktop

      if ! git diff --quiet -- flake.lock; then
        echo "Note: flake.lock changed — commit and push it when convenient."
      fi
    '')
    (pkgs.writeShellScriptBin "nrb" ''
      set -e
      cd /home/callum/.config/nixos

      echo "==> Updating flake inputs..."
      nix flake update

      echo "==> Rebuilding (boot)..."
      sudo nixos-rebuild boot --flake .#desktop

      if ! git diff --quiet -- flake.lock; then
        echo "Note: flake.lock changed — commit and push it when convenient."
      fi
    '')
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
