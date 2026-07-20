# Boot loader — systemd-boot with Windows dual boot support
{ ... }:

{
  boot.loader = {
    systemd-boot = {
      enable = true;
      # systemd-boot automatically detects the Windows Boot Manager if it
      # lives on the same EFI System Partition — no os-prober needed.
      #
      # Windows usually creates a small (~100 MB) ESP. Keep the generation
      # count low so kernels/initrds don't fill it. If you created a bigger
      # dedicated ESP (1 GB), feel free to raise this.
      configurationLimit = 5;
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
