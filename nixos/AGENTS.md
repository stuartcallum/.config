# Agent instructions — nixos/

Read `README.md` first for the full picture (layout, install steps, day-to-day
commands). This file is the shorter set of rules for any AI agent (Claude
Code, Codex, Cursor, etc.) editing files under this directory.

## The one hard rule: rebuild after every change

Any time you edit, add, or remove a file under `nixos/`, you must apply it
by running the `nrs` shortcut before considering the task done:

```sh
nrs   # = sudo nixos-rebuild switch --flake /home/callum/.config/nixos#desktop
```

This actually builds the new generation and switches the running system to
it — not a dry run. If it fails, the config is broken; fix the error and run
`nrs` again rather than leaving a change unapplied or unverified.

**New files must be `git add`ed first.** Flakes only evaluate git-tracked
files. A brand-new module that hasn't been staged will be silently invisible
to `nixos-rebuild` and `nrs` will build as if the file doesn't exist —
this is the most common way an agent's change appears to do nothing. Run
`git add <new files>` before `nrs` whenever you create a file.

If you want a cheaper sanity check while iterating before the real switch,
`nix flake check` or `sudo nixos-rebuild dry-build --flake .#desktop` catch
eval errors without touching the running system — but `nrs` is still the
required final step once the change is ready.

Don't run `nru` (`git push` + snapshot + `nix flake update` + rebuild)
unless the user explicitly asks for it — it updates pinned inputs and
pushes to the remote, which are bigger, less reversible actions than a
plain rebuild.

## Layout and conventions

- One host so far: `hosts/desktop/`. Host-specific config (hostname, which
  session to boot into, feature toggles) goes in `hosts/desktop/default.nix`;
  anything reusable across a hypothetical future host goes in `modules/`.
- `modules/` is grouped by concern (`core`, `desktop`, `networking`, `gaming`,
  `dev`, `system`, `hardware`). Each group has a `default.nix` that imports
  its siblings — add new files there and wire them into that `default.nix`,
  don't import loose files directly from the host.
- Custom toggles follow the `my.<area>.<option>` pattern already used for
  `my.desktop.session` (`modules/desktop/default.nix`) and
  `my.gaming.retro.enable` (`modules/gaming/retro.nix`) — prefer extending
  that pattern over ad hoc booleans.
- Packages come from **nixos-26.05** (stable) by default. Only reach for the
  `pkgs.unstable` overlay (defined in `flake.nix`) for the specific packages
  that already use it (neovim, ghostty, steam/proton-GE) unless there's a
  concrete reason a package needs to track unstable — comment why if you add
  one.
- `secrets/` is gitignored (OpenVPN profile with an inline private key).
  Never commit anything there, and don't move it between machines other than
  by hand.
- `system.stateVersion` in `hosts/desktop/default.nix` is set once at install
  and must never change afterwards.
- Keep comments in the terse, why-not-what style already used throughout
  these files (see any existing module) — one line explaining a non-obvious
  choice, not a restatement of the option name.

## Background automation you should know about

This machine runs several unattended systemd timers. None of them replace
`nrs` — they exist for when nobody's watching, not for verifying your edits
— but they can be surprising if you don't know they're there:

- **`config-repo-sync`** (`modules/system/config-repo.nix`) fast-forward
  pulls this repo from GitHub daily at 03:30. If you leave local commits
  unpushed, the sync just skips silently that day — it never overwrites or
  rebases your work. But it also means the *deployed* machine can drift from
  what an agent working in a fresh clone sees, if commits made elsewhere
  haven't been pushed yet.
- **`nixos-upgrade`** (`modules/system/auto-update.nix`) rebuilds nightly at
  04:00 against the latest nixpkgs commits, activating on next boot
  (`operation = "boot"`, `allowReboot = false`) — it never live-switches or
  reboots on its own. It does **not** touch `flake.lock`
  (`--no-write-lock-file`), so this never shows up as an uncommitted diff.
- A btrfs snapshot of `/` and `/home` is taken automatically right before
  that nightly upgrade (`modules/system/snapshots.nix`), and snapshots older
  than 14 days are pruned daily at 05:00. `sudo nix-snapshot` takes one
  on-demand; recover with `cp` from `/.snapshots/<name>/...`.
- **Secure Boot** is handled by lanzaboote (`modules/system/secure-boot.nix`),
  which signs the kernel/initrd/bootloader as part of every `nrs`. You don't
  need to do anything extra for this — just know that if `nrs` succeeds, the
  boot chain is already correctly signed.
- `secrets/` (the OpenVPN profile with its private key) is gitignored and
  will not exist in a fresh clone or worktree — don't try to read, generate,
  or "fix" it; its absence there is expected, not a bug.
- `system.stateVersion` in `hosts/desktop/default.nix` was set once at
  install and must never be changed, even when bumping the nixpkgs input.
