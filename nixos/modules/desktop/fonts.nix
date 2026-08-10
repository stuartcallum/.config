# System fonts. No font packages were installed before this, which is why
# glyphs kept going missing — emoji, CJK, and the Nerd Font icons waybar's
# style.css asks for ("Nerd Font Hack") all fell back to nothing.
{ pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      liberation_ttf # metric-compatible with Arial/Times/Courier
      dejavu_fonts # common fallback many apps assume exists
      font-awesome # icon glyphs used by web content and some apps/toolkits
      source-sans
      source-serif
      ubuntu-classic
      cascadia-code # popular coding font, complements Hack
      nerd-fonts.hack # "Hack Nerd Font" — used by waybar for icon glyphs
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "Hack Nerd Font Mono" "Noto Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };
}
