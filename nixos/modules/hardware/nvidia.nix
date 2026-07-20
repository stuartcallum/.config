# NVIDIA proprietary driver — import from hosts/desktop/default.nix if the
# machine has an NVIDIA GPU. (AMD GPUs need nothing: amdgpu is in the kernel
# and hardware.graphics is already enabled by the gaming module.)
{ config, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true; # required for Wayland (GNOME + Hyprland)
    open = true;               # open kernel module — right choice for RTX 20xx+;
                               # set false for GTX 10xx and older
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
