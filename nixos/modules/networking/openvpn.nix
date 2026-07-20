# OpenVPN tunnel to the other house.
#
# Drop your client profile at /home/callum/.config/nixos/secrets/house.ovpn
# (the secrets/ directory is gitignored — never commit it). If the profile
# references separate cert/key files, put them in secrets/ too and use
# relative paths inside the .ovpn.
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
