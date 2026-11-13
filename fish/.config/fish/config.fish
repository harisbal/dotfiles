set -g fish_greeting
fish_add_path $HOME/.npm-global/bin $HOME/.local/bin $HOME/.cargo/bin
set -gx EDITOR nvim

if status is-interactive
    command -q starship; and starship init fish | source
    command -q zoxide;   and zoxide init fish | source
    command -q fzf;      and fzf --fish | source
    command -q direnv;   and direnv hook fish | source
    if command -q eza
        alias ls 'eza --icons=auto'
        alias ll 'eza --icons=auto -l'
        alias la 'eza --icons=auto -a'
        alias lt 'eza --icons=auto --tree'
        alias lla 'eza --icons=auto -la'
    end
    command -q bat; and alias cat bat
    alias vi nvim
    alias vim nvim
end
