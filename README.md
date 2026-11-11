# .config

macOS dotfiles (`~/.config`).

Files that live outside `~/.config` are kept here and symlinked into place:

```sh
ln -s ~/.config/zsh/.zprofile ~/.zprofile
ln -s ~/.config/ssh/config ~/.ssh/config
```

SSH keys are never committed — only `ssh/config`.

## Private bits kept out of this public repo

- **Work SSH hosts** live in `ssh/work` (gitignored), pulled in by `Include` at the top of `ssh/config`.
- **Zed** `proxy` and `ssh_connections` are stripped from `zed/settings.json` on commit by a git filter. After cloning, enable it before committing:

  ```sh
  git config filter.zed-private.clean scripts/zed-clean.sh
  git config filter.zed-private.smudge cat
  git config filter.zed-private.required true
  ```
