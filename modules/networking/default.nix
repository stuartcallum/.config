# Networking — wifi and VPN
{ ... }:

{
  imports = [
    ./wifi.nix
    ./openvpn.nix
  ];

  networking.firewall.enable = true;
}
