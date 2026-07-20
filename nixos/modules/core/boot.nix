# Boot loader — systemd-boot with Windows dual boot support
{ ... }:

{
  boot.loader = {
    systemd-boot = {
      enable = true;
      # systemd-boot automatically detects the Windows Boot Manager if it
      # lives on the same EFI System Partition — no os-prober needed.
      #
      # The shared ESP is 1 GiB (rebuilt during the Windows boot repair),
      # so there's room for a healthy number of generations.
      configurationLimit = 15;
      editor = false; # don't allow editing kernel params at boot (security)
    };
    efi.canTouchEfiVariables = true;
    # Give yourself time to pick Windows at the boot menu
    timeout = 5;
  };

  # Windows expects the hardware clock in local time; Linux defaults to UTC.
  # Without this, clocks drift every time you switch OS.
  time.hardwareClockInLocalTime = true;

  # NTFS support so the Windows partition can be mounted read/write if needed
  boot.supportedFilesystems = [ "ntfs" ];
}
