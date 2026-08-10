# Firmware updates (BIOS, SSD, peripherals) via LVFS.
# Check/apply with: fwupdmgr refresh && fwupdmgr get-updates && fwupdmgr update
{ ... }:

{
  services.fwupd.enable = true;
}
