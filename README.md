# Dotfiles

Personal config, laid out as [GNU Stow](https://www.gnu.org/software/stow/) packages (each top-level
folder mirrors `$HOME`). This is a **non-Nix mirror** of my NixOS setup, so I can move to another distro
(Arch/Fedora/Debian/...) without rebuilding it from scratch. The source of truth while I'm on NixOS is the private
`nixos-config` repo (`home/*.nix`); the files here were generated from it (waybar JSON/CSS straight from the
evaluated config, the Hyprland Lua verbatim). Last synced from `nixos-config` at `32a977d` (2026-11-19); re-sync
by hand when the Nix config changes, since nothing automates it.

```sh
git clone https://github.com/harisbal/dotfiles ~/dotfiles && cd ~/dotfiles
stow hypr waybar swayosd ghostty kitty fish tmux nvim git npm starship claude
```

| package | what | notes |
|---|---|---|
| `hypr` | Hyprland (`hyprland.lua`), hypridle, hyprpaper, `compact-workspaces`, wallpaper | needs Hyprland >= 0.55 (Lua config). `SUPER+SHIFT+C` renumbers non-empty workspaces to 1..n. Closing the lid turns `eDP-1` off while an external monitor is connected |
| `waybar` | top bar, transopt.io teal + orange; bluetooth module opens blueman | font: MesloLGS Nerd Font |
| `swayosd` | volume/brightness popup style (`~/.config/swayosd/style.css`) | `swayosd-server` is started from `hyprland.lua` |
| `ghostty`, `kitty` | terminals, Catppuccin Mocha, 0.92 opacity | |
| `fish` | config + `cc` (persistent Claude tmux session), `gws-*` | |
| `tmux` | prefix `C-s`, TPM plugins (auto-installs TPM) | `prefix + I` installs plugins |
| `nvim` | lazy.nvim, native LSP, telescope, oil, blink.cmp, ... | Neovim >= 0.11 |
| `claude` | Claude Code status line script (`~/.claude/statusline.sh`, needs `jq`) | add `"statusLine": {"type": "command", "command": "bash ~/.claude/statusline.sh"}` to `~/.claude/settings.json` by hand (Claude rewrites that file, so it isn't stowed) |
| `git`, `npm`, `starship` | git identity + gh credential helper, npm global prefix, prompt | run `gh auth login` once |

## Packages to install (what NixOS provided)

- **Desktop:** hyprland, hyprlock, hypridle, hyprpaper, hyprpolkitagent, hyprshot, waybar, wofi, dunst, swappy, grim,
  slurp, wl-clipboard, cliphist, brightnessctl, playerctl, wlogout, pavucontrol, network-manager-applet, swayosd, blueman (+ bluez, bluetooth service enabled), dolphin
- **Shell/CLI:** fish, starship, zoxide, fzf, eza, bat, direnv, tmux, git, gh, jq, ripgrep, fd, lazygit, uv, ghostty, kitty
- **Neovim tooling** (Mason or the distro): lua-language-server, pyright, ruff, rust-analyzer (via rustup),
  typescript-language-server, vscode-langservers-extracted, marksman, taplo, yaml-language-server,
  bash-language-server, stylua, shfmt, prettier (add `nil` + `nixpkgs-fmt` only if you still write Nix)
- **Fonts:** MesloLGS Nerd Font

## Not mirrored

System-level settings (users, networking, Tailscale, Docker, NVIDIA, SDDM, UWSM session), the systemd timers
(`ibkr-daily`, `diavgeiaplus`, which need a secrets env file), and the laptop/desktop host configs. Those stay in
`nixos-config`. Without UWSM, start Hyprland from your display manager or `Hyprland` on a TTY; the autostart
block at the bottom of `hyprland.lua` launches waybar, hyprpaper, hypridle, dunst, swayosd-server, the polkit agent, nm-applet and blueman-applet.
