#!/bin/bash

if [ -f "$HOME/.zshrc" ]; then
  source "$HOME/.zshrc"
fi

plugins=(
  "zsh-users/zsh-autosuggestions"
  "zsh-users/zsh-syntax-highlighting"
  "romkatv/powerlevel10k"
  "zsh-users/zsh-history-substring-search"
  "MichaelAquilina/zsh-auto-notify"
  "MichaelAquilina/zsh-you-should-use"
  # "chrissicool/zsh-256color"
)
# For more plugins: https://github.com/unixorn/awesome-zsh-plugins
# More completions https://github.com/zsh-users/zsh-completions

completions=(
  "esc/conda-zsh-completion"
)

# -----------------------------------------------------------------------------

# bashrc="$HOME/.local/share/omarchy/default/bash/zshrc"
# if [ -f "$bashrc" ]; then
#     source "$bashrc"
# fi

# Plubin Functions
source "$ZDOTDIR/plugin-functions.sh"

# Normal files to source
for f in "$ZDOTDIR/source"/*; do
  zsh_add_file "$f"
done

for f in "$ZDOTDIR/scripts"/*; do
  target="$HOME/.local/bin/$(basename "$f")"
  if [ -f "$target" ]; then
    continue
  fi
  ln -sT "$f" "$target"
  chmod +x "$target"
done

for f in "$ZDOTDIR/file-plugins"/*; do
  zsh_add_file "$f"
done

# Plugins
for plugin in "${plugins[@]}"; do
  zsh_add_plugin "$plugin"
done

# Completions
for completion in "${completions[@]}"; do
  zsh_add_completion "$completion" true
done

# Source plugins config files
for f in "$ZDOTDIR/plugins-config"/*; do
  zsh_add_file "$f"
done

# fastfetch
