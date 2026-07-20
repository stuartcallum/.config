# Btrfs snapshots — file-level recovery for / and /home.
#
# (Bootable system rollback is already handled by NixOS generations in the
# systemd-boot menu; snapshots protect data those don't cover.)
#
#   sudo nix-snapshot        take a read-only snapshot of / and /home now
#   ls /.snapshots           browse; restore files with plain cp
#
# Automatic behaviour:
#   - a snapshot is taken right before the nightly 04:00 auto-upgrade
#   - snapshots older than 14 days are pruned daily at 05:00
{ pkgs, ... }:

let
  nix-snapshot = pkgs.writeShellScriptBin "nix-snapshot" ''
    set -eu
    dest=/.snapshots
    stamp=$(date +%Y-%m-%d_%H-%M-%S)
    mkdir -p "$dest"
    ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /     "$dest/root-$stamp"
    ${pkgs.btrfs-progs}/bin/btrfs subvolume snapshot -r /home "$dest/home-$stamp"
    echo "created $dest/root-$stamp and $dest/home-$stamp"
  '';
in
{
  environment.systemPackages = [ nix-snapshot pkgs.btrfs-progs ];

  # Snapshot before the nightly auto-upgrade builds the new system
  systemd.services.nixos-upgrade.preStart = "${nix-snapshot}/bin/nix-snapshot";

  # Prune snapshots older than 14 days (matches the nix-gc retention window)
  systemd.services.snapshot-prune = {
    description = "Delete btrfs snapshots older than 14 days";
    serviceConfig.Type = "oneshot";
    script = ''
      cutoff=$(date -d "14 days ago" +%Y-%m-%d)
      for snap in /.snapshots/root-* /.snapshots/home-*; do
        [ -d "$snap" ] || continue
        # snapshot names embed their creation date: root-YYYY-MM-DD_HH-MM-SS
        d=$(basename "$snap" | cut -d- -f2-4 | cut -d_ -f1)
        if [ "$d" \< "$cutoff" ]; then
          ${pkgs.btrfs-progs}/bin/btrfs subvolume delete "$snap"
        fi
      done
    '';
  };
  systemd.timers.snapshot-prune = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "05:00";
      Persistent = true;
    };
  };
}
