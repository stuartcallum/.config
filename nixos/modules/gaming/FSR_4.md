# FSR 4 on this GPU (RX 7700/7800 XT — RDNA3 / GFX11)

**Compatible: yes.** FSR 4 originally launched RDNA4-only, but AMD officially
extended it to RDNA3 (FSR 4.1, via Adrenalin driver 26.6.2, June 2026) using
FP8/INT8 emulation instead of RDNA4's dedicated AI accelerators. That's a
Windows/Adrenalin-side rollout, but the same work is landing in the
open-source Linux stack: Mesa's RADV Vulkan driver has active FSR 4 support
for GFX11 (RDNA3), including the FP8 emulation path AMD's driver uses.

**What this config does about it:** nothing special — Mesa comes from
stable nixpkgs. It used to be pinned to `pkgs.unstable.mesa` system-wide,
but that broke the desktop (Oct 2026): unstable moved to glibc 2.43 while
stable was on 2.42, so gnome-shell couldn't load the driver and died with
"No GPUs found". Don't re-pin the system driver to unstable unless both
channels are on the same glibc.

**What this config does NOT do:** turn FSR 4 on in any particular game. FSR
is invoked by the game (or by Proton translating DX to Vulkan) via AMD's
FidelityFX SDK — there's no global "enable FSR 4" switch. Per game:
- Native Linux titles: enable AMD FSR / "FSR 4" in the game's own graphics
  settings, if it offers the option.
- Windows titles via Proton: same, from in-game settings, once Proton/DXVK
  routes the relevant calls through to RADV's implementation.

Because this is genuinely bleeding-edge (patches were still actively
landing as of mid-2026), some titles may not pick it up yet even with an
up-to-date Mesa — check a game's FSR version/quality menu to confirm what's
actually running. If nothing appears, it may need a newer Mesa than stable
ships yet.
