# Right Shift is temporarily remapped to Escape while the physical Escape
# key is broken. keyd remaps at the evdev level (below X11/Wayland), so
# unlike a GNOME/XKB-level remap it works for every window regardless of
# whether it's a native Wayland client or an XWayland one.
# Revert by removing this file's import in ./default.nix once Escape works again.
{ ... }:

{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.rightshift = "esc";
    };
  };
}
