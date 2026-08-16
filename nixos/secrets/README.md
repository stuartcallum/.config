# secrets/

This directory is **gitignored**. Put private material here:

- `house.ovpn` — the OpenVPN client profile for the tunnel to the other
  house (referenced by `modules/networking/openvpn.nix`). If it needs
  separate `ca.crt` / `client.key` files, put them here too and reference
  them with relative paths inside the `.ovpn`.
- `nzbget-credentials.conf` — news-server passwords and the NZBGet web-UI
  password (referenced by `modules/gaming/nzbget.nix`, which appends it to
  `/var/lib/nzbget/nzbget.conf` on every service start). The `ServerN`
  numbering must stay in step with the `servers` list in that module.
  Without this file the nzbget service refuses to start.

Nothing in here is copied into the nix store; the OpenVPN service reads the
profile from this path at runtime.
