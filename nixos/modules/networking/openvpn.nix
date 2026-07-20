# OpenVPN tunnel to the other house (TP-Link router at calstu.tplinkdns.com).
#
# The client profile lives at /home/callum/.config/nixos/secrets/house.ovpn —
# self-contained with inline ca/cert/key. secrets/ is gitignored and the
# .config repo is PUBLIC, so the profile must be copied to the machine
# out-of-band (USB stick), not via git clone.
#
# If OpenVPN 2.6 refuses the router's legacy cipher with a "cipher not
# allowed" error, append this line to house.ovpn:
#   data-ciphers-fallback AES-128-CBC
{ ... }:

{
  services.openvpn.servers.house = {
    # Referenced as a plain string path at runtime, so the credentials are
    # NOT copied into the world-readable nix store.
    config = "config /home/callum/.config/nixos/secrets/house.ovpn";

    # Start on demand rather than at boot:
    #   sudo systemctl start openvpn-house
    #   sudo systemctl stop openvpn-house
    # Flip to true if you want it always on.
    autoStart = false;

    updateResolvConf = true;
  };
}
