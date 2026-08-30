# secrets/

This directory is **gitignored**. Put private material here:

- `house.ovpn` — the OpenVPN client profile for the tunnel to the other
  house (referenced by `modules/networking/openvpn.nix`). If it needs
  separate `ca.crt` / `client.key` files, put them here too and reference
  them with relative paths inside the `.ovpn`.

Nothing in here is copied into the nix store; the OpenVPN service reads the
profile from this path at runtime.
