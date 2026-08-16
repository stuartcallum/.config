# NZBGet — usenet downloader feeding the ROM library.
# Flip on with `my.gaming.nzbget.enable = true;` in the host config.
#
# Web UI: http://127.0.0.1:6789 (user nzbget). Bound to loopback only, so
# nothing is exposed to the LAN and no firewall hole is needed.
#
# Completed downloads land in ~/Games/roms/downloads/<category>; the only
# category defined is `games`, matching the directory already in use there.
#
# Passwords live in secrets/nzbget-credentials.conf and are injected at
# runtime — see the preStart below for why they can't go in `settings`.
{ config, lib, pkgs, ... }:

let
  cfg = config.my.gaming.nzbget;

  destDir = "/home/callum/Games/roms/downloads";
  stateDir = "/var/lib/nzbget";
  credentialsFile = "/home/callum/.config/nixos/secrets/nzbget-credentials.conf";

  # News servers in the order they should be tried: Level 0 is the primary,
  # each higher level is only asked for articles the levels above it missed.
  #
  # Australian servers first (lowest latency from here); within a tier the
  # provider's own priority ranking breaks the tie. newsgroupdirect is a
  # metered 562G block account, so it sits last regardless of its ranking —
  # it should only ever fill articles the unmetered servers can't supply.
  #
  # Two servers sharing a Level are load-balanced across, not ordered.
  servers = [
    { name = "blocknews-au"; host = "aunews.blocknews.net"; username = "calinux"; level = 0; }
    { name = "frugal-au"; host = "aunews.frugalusenet.com"; username = "calinux"; level = 1; }
    { name = "blocknews-us"; host = "usnews.blocknews.net"; username = "calinux"; level = 2; }
    { name = "frugal-us"; host = "news.frugalusenet.com"; username = "calinux"; level = 3; }
    {
      name = "newsgroup-ninja";
      host = "news.newsgroup.ninja";
      username = "UJAAXRPHETKI";
      level = 3;
      active = false;
      connections = 20;
      notes = "Disabled upstream";
    }
    { name = "frugal-bonus"; host = "bonus.frugalusenet.com"; username = "calinux"; level = 4; }
    {
      name = "newsgroupdirect";
      host = "news.newsgroupdirect.com";
      username = "ipg551923544";
      level = 5;
      retention = 5742;
      notes = "Block account - 562G quota, kept last";
    }
  ];

  # `Password` is deliberately absent — it comes from credentialsFile.
  mkServer =
    i: s:
    lib.mapAttrs' (k: v: lib.nameValuePair "Server${toString i}.${k}" v) {
      Name = s.name;
      Active = s.active or true;
      Level = s.level;
      Optional = false;
      Group = 0;
      Host = s.host;
      Port = 563;
      Username = s.username;
      JoinGroup = false;
      Encryption = true;
      Cipher = "";
      CertVerification = "strict";
      Connections = s.connections or 30;
      Retention = s.retention or 0;
      IpVersion = "auto";
      Notes = s.notes or "";
    };
in
{
  options.my.gaming.nzbget.enable = lib.mkEnableOption "NZBGet usenet downloader";

  config = lib.mkIf cfg.enable {
    services.nzbget = {
      enable = true;

      # Runs as callum rather than a dedicated nzbget system user: both the
      # download target and the credentials file live under /home/callum, and
      # a separate user would need ACLs on both to reach them.
      user = "callum";
      group = "users";

      settings = lib.foldl' lib.mergeAttrs {
        MainDir = stateDir;
        DestDir = destDir;

        # In-progress files stay on the destination filesystem so finishing a
        # download is a rename, not a full copy across subvolumes.
        InterDir = "${destDir}/.incomplete";

        # Drop .nzb files here and they're queued automatically.
        NzbDir = "${destDir}/watch";
        QueueDir = "${stateDir}/queue";
        TempDir = "${stateDir}/tmp";
        ScriptDir = "${stateDir}/scripts";

        # Refuse to start if the ROM volume isn't mounted, rather than
        # quietly filling the root filesystem in its place.
        RequiredDir = destDir;
        CertStore = "/etc/ssl/certs/ca-certificates.crt";

        # Loopback only — reach the UI from this machine, or over SSH.
        ControlIP = "127.0.0.1";
        ControlPort = 6789;
        ControlUsername = "nzbget";
        FormAuth = true;
        SecureControl = false;
        AuthorizedIP = "";

        # Verify news-server certs; without this Encryption=yes is theatre.
        CertCheck = true;

        # Quoted: these are flat nzbget option names, not nested attributes.
        "Category1.Name" = "games";
        "Category1.Unpack" = true;
        "Category1.Aliases" = "games*, pc*, apps*";
        AppendCategoryDir = true;

        NzbDirInterval = 5;
        # Ignore .nzb files still being written.
        NzbDirFileAge = 60;
        DupeCheck = true;

        # 800M of article cache paired with DirectWrite keeps assembly in RAM
        # (30G on this box) instead of scattering thousands of small writes.
        ArticleCache = 800;
        DirectWrite = true;
        WriteBuffer = 1024;

        FileNaming = "article";
        RenameAfterUnpack = true;
        ReorderFiles = true;
        PostStrategy = "balanced";

        # Pause the queue below 20G free — a real limit on this disk, not a
        # formality. Raise it if downloads start stalling mid-job.
        DiskSpace = 20000;
        NzbCleanupDisk = true;
        KeepHistory = 30;

        ArticleRetries = 3;
        ArticleInterval = 10;
        ArticleTimeout = 60;
        UrlRetries = 3;
        UrlTimeout = 60;
        # 0 = unthrottled; set in KB/s to cap.
        DownloadRate = 0;
        MonthlyQuota = 0;
        DailyQuota = 0;

        # auto = only verify when something looks wrong; ParThreads 0 uses
        # all 8 cores when a repair actually is needed.
        ParCheck = "auto";
        ParRepair = true;
        ParScan = "extended";
        ParQuick = true;
        ParThreads = 0;
        ParBuffer = 500;
        ParRename = true;
        RarRename = true;
        DirectRename = true;
        # Bin releases par2 says are beyond repair.
        HealthCheck = "delete";

        Unpack = true;
        DirectUnpack = true;
        UseTempUnpackDir = true;
        UnpackCleanupDisk = true;
        ExtCleanupDisk = ".par2, .sfv, _brokenlog.txt";

        # Group-writable so the emulators (and you) can move ROMs around
        # without sudo.
        UMask = "0002";
      } (lib.imap1 mkServer servers);
    };

    # Credentials are appended to the runtime config here instead of going
    # through services.nzbget.settings, because that option is handed to
    # nzbget as `-o Name=value` on the command line — which would put every
    # password in the world-readable unit file and in `ps` output for any
    # local user to read. Same reasoning as the OpenVPN profile: referenced
    # by path at runtime, never copied into the nix store.
    #
    # Stripping before appending keeps this idempotent across restarts.
    systemd.services.nzbget.preStart = lib.mkAfter ''
      if [ ! -r ${credentialsFile} ]; then
        echo "nzbget: cannot read ${credentialsFile} — copy it to this machine by hand" >&2
        exit 1
      fi
      umask 077
      ${pkgs.gnused}/bin/sed -i -E '/^(Server[0-9]+\.Password|ControlPassword)=/d' ${stateDir}/nzbget.conf
      ${pkgs.coreutils}/bin/cat ${credentialsFile} >> ${stateDir}/nzbget.conf
      ${pkgs.coreutils}/bin/chmod 0600 ${stateDir}/nzbget.conf
    '';

    systemd.tmpfiles.rules = [
      "d ${destDir}             0755 callum users -"
      "d ${destDir}/watch       0755 callum users -"
      "d ${destDir}/.incomplete 0755 callum users -"
    ];
  };
}
