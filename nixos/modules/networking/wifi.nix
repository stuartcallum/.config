# Wifi drivers and configuration
{ ... }:

{
  # Firmware blobs for wifi/bluetooth chips (Intel, Realtek, Broadcom, ...).
  # This covers the large majority of desktop wifi cards.
  hardware.enableRedistributableFirmware = true;

  # NetworkManager handles wifi. Manage connections from the GNOME settings
  # panel, nm-applet (Hyprland), or `nmtui` / `nmcli` in a terminal.
  networking.networkmanager = {
    enable = true;
    # Desktop PC on mains power — don't trade latency for power savings
    wifi.powersave = false;
  };

  # Bluetooth (most wifi cards ship a combo chip)
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
}
