# Gaming system tuning — kernel knobs, scheduler and limits only.
# The gaming *software* (Steam, Proton, gamescope, Mesa) lives in ./default.nix.
{ pkgs, ... }:

{
  boot.kernel.sysctl = {
    # DXVK/vkd3d map a great many small memory regions; the stock 65530 limit
    # is enough to crash some titles outright. This is the value Valve ships
    # on the Steam Deck.
    "vm.max_map_count" = 2147483642;

    # zram is the only swap on this machine (see ./default.nix), and paging to
    # compressed RAM is far cheaper than evicting the game's page cache — so
    # swap eagerly, and skip readahead since zram reads are effectively random.
    "vm.swappiness" = 180;
    "vm.page-cluster" = 0;

    # Reclaim a little earlier and without the fragmentation-avoidance boost,
    # so a texture-streaming spike finds free pages instead of stalling in
    # direct reclaim mid-frame.
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;

    # Anti-cheat and some Unity/Unreal titles trigger split-lock atomics. The
    # kernel's mitigation punishes them with a forced sleep, which shows up as
    # multi-second freezes; warn instead of throttling.
    "kernel.split_lock_mitigate" = 0;

    # Lower handshake latency for online play (client and server side).
    "net.ipv4.tcp_fastopen" = 3;
  };

  # Wine/Proton's esync opens one eventfd per synchronisation object and runs
  # into the 1024 soft limit quickly. PAM limits cover graphical logins, which
  # is where Steam actually starts.
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "524288";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }

    # RPCS3 mlocks its 2 GiB guest memory region so the PS3 address space is
    # never paged out mid-frame; the stock 8 MiB cap makes every lock fail and
    # it falls back to a slower path. It raises its own soft limit on startup,
    # so the hard value is the one that actually has to clear 2 GiB.
    {
      domain = "*";
      type = "soft";
      item = "memlock";
      value = "2097152";
    }
    {
      domain = "*";
      type = "hard";
      item = "memlock";
      value = "4194304";
    }
  ];

  # Both need CAP_SYS_NICE to raise priority for the game's threads —
  # without it gamescope's frame pacing and gamemode's renice quietly no-op.
  programs.gamescope.capSysNice = true;
  programs.gamemode.enableRenice = true;

  # sched_ext: LAVD ("Latency-criticality Aware Virtual Deadline") is the
  # scheduler CachyOS ships for gaming — it identifies latency-sensitive
  # threads (render, audio) and schedules them ahead of background work.
  # Only the Rust schedulers are installed, not all of scx.full. The unit
  # skips itself if the kernel lacks sched_ext, and if the BPF scheduler
  # ever misbehaves the kernel drops back to EEVDF on its own.
  services.scx = {
    enable = true;
    package = pkgs.scx.rustscheds;
    scheduler = "scx_lavd";
  };
}
