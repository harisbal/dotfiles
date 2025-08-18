
# Dotfiles

This repository contains my personal configuration files (dotfiles) for various tools:

- **tmux**: Terminal multiplexer with custom keybindings (Ctrl-s as leader, hjkl navigation) and Catppuccin theme.
- **Neovim**: Neovim configuration with lazy.nvim plugin manager and Catppuccin theme.
- **Other tools**: Add more configurations as needed.

## Installation

Clone this repository and create symbolic links to your home directory:

```bash
# Clone the repo
git clone git@github.com:yourusername/dotfiles.git ~/dotfiles

# Link tmux config
ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf

# Link Neovim config
# ln -s ~/dotfiles/nvim ~/.config/nvim

