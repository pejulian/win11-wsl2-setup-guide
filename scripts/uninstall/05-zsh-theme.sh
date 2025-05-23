#!/usr/bin/env zsh

# ===================================
# Load commons
# ===================================
source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

uninstall_powerlevel10k() {
  local theme_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
  local zshrc="$ZSHRC_FILE"
  local theme_line='ZSH_THEME="powerlevel10k/powerlevel10k"'
  local p10k_include='[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh'
  local config_path="$HOME/.p10k.zsh"
  local default_theme_line='ZSH_THEME="robbyrussell"'

  # Remove Powerlevel10k theme directory
  if [[ -d "$theme_dir" ]]; then
    echo "Removing Powerlevel10k theme directory at $theme_dir..."
    rm -rf "$theme_dir"
    echo "Powerlevel10k theme directory removed."
  else
    echo "Powerlevel10k theme directory not found. Skipping removal."
  fi

  # Remove Powerlevel10k theme line from .zshrc and reset to default theme
  if grep -q "^$theme_line" "$zshrc"; then
    echo "Resetting ZSH_THEME to default (robbyrussell) in .zshrc..."
    sed -i "s|^$theme_line|$default_theme_line|" "$zshrc"
    echo "ZSH_THEME reset to default (robbyrussell)."
  else
    echo "Powerlevel10k theme line not found in .zshrc. Skipping."
  fi

  # Remove .p10k.zsh include from .zshrc
  if grep -Fxq "$p10k_include" "$zshrc"; then
    echo "Removing .p10k.zsh include from .zshrc..."
    escaped_p10k_include=$(echo "$p10k_include" | sed 's/[]\/$*.^[]/\\&/g') # Escape special characters
    sed -i "/$escaped_p10k_include/d" "$zshrc"
    echo ".p10k.zsh include removed from .zshrc."
  else
    echo ".p10k.zsh include not found in .zshrc. Skipping."
  fi

  # Remove .p10k.zsh configuration file
  if [[ -f "$config_path" ]]; then
    echo "Removing .p10k.zsh configuration file at $config_path..."
    rm -f "$config_path"
    echo ".p10k.zsh configuration file removed."
  else
    echo ".p10k.zsh configuration file not found. Skipping removal."
  fi

  echo "Powerlevel10k uninstallation completed."
}

uninstall_powerlevel10k

