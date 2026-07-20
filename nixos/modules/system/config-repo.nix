# Keeps /home/callum/.config in sync with github.com/stuartcallum/.config.
#
# Runs at boot and daily at 03:30 (just before the 04:00 auto-upgrade, so the
# nightly rebuild always uses the latest pushed config):
#   - no repo yet  -> initialises ~/.config from GitHub in place
#   - repo present -> fast-forward pull; local commits or conflicting edits
#                     are left untouched (sync just skips that day)
#
# Check on it with: systemctl status config-repo-sync
{ pkgs, ... }:

{
  systemd.services.config-repo-sync = {
    description = "Sync ~/.config from GitHub";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.git ];
    serviceConfig = {
      Type = "oneshot";
      User = "callum";
    };
    script = ''
      dir=/home/callum/.config
      repo=https://github.com/stuartcallum/.config.git

      if [ ! -d "$dir/.git" ]; then
        # First run: apps may already have dropped files in ~/.config, so a
        # plain clone would refuse. Initialise in place instead; -f lets
        # tracked files from the repo win over anything in the way.
        mkdir -p "$dir"
        cd "$dir"
        git init -b master
        git remote add origin "$repo"
        git fetch origin
        git checkout -f -t origin/master
      else
        cd "$dir"
        git pull --ff-only origin master \
          || echo "config-repo-sync: local changes present, skipping pull"
      fi
    '';
  };

  systemd.timers.config-repo-sync = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "03:30";
      RandomizedDelaySec = "10m";
      Persistent = true;
    };
  };
}
