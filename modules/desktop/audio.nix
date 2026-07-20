# Audio via PipeWire (with PulseAudio and ALSA compatibility)
{ ... }:

{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true; # 32-bit games need this
    pulse.enable = true;
  };
}
