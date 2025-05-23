#!/usr/bin/env zsh

# ===================================
# Load commons
# ===================================
source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

clone_powerlevel10k() {
  local theme_dir="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

  if [[ -d "$theme_dir" ]]; then
    echo "Powerlevel10k is already cloned at $theme_dir. Skipping clone."
  else
    echo "Cloning Powerlevel10k into $theme_dir..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$theme_dir"
    if [[ $? -eq 0 ]]; then
      echo "Powerlevel10k successfully cloned."
    else
      echo "Failed to clone Powerlevel10k. Please check your internet connection or permissions."
      exit 1
    fi
  fi
}

install_powerlevel10k() {
  local zshrc="$ZSHRC_FILE"
  local theme_line='ZSH_THEME="powerlevel10k/powerlevel10k"'
  local p10k_include='[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh'

  # Ensure theme is set
  if grep -q '^ZSH_THEME=' "$zshrc"; then
    if ! grep -q "^$theme_line" "$zshrc"; then
      echo "Updating ZSH_THEME to powerlevel10k..."
      sed -i "s|^ZSH_THEME=.*|$theme_line|" "$zshrc"
    fi
  else
    echo "Adding ZSH_THEME for powerlevel10k..."
    echo "$theme_line" >> "$zshrc"
  fi

  # Add p10k include after oh-my-zsh if not already present
  if ! grep -Fxq "$p10k_include" "$zshrc"; then
    echo "Inserting .p10k.zsh include after oh-my-zsh.sh source line..."
    awk -v inc="$p10k_include" '
      {
        print
        if ($0 ~ /source \$ZSH\/oh-my-zsh.sh/) {
          print inc
        }
      }
    ' "$zshrc" > "$zshrc.tmp" && mv "$zshrc.tmp" "$zshrc"
  else
    echo ".p10k.zsh include already present in .zshrc."
  fi
}

applyP10kTheme() {
  local config_path="$HOME/.p10k.zsh"
  local source_config="./scripts/common/p10k.zsh"

  if [[ -f "$config_path" ]]; then
    echo "Powerlevel10k configuration file already exists at $config_path. Skipping."
  else
    if [[ -f "$source_config" ]]; then
      echo "Copying default Powerlevel10k configuration file to $config_path..."
      cp "$source_config" "$config_path"
      echo "Default Powerlevel10k configuration file copied successfully."
    else
      echo "Source configuration file $source_config not found. Please ensure it exists."
      exit 1
    fi

    if [[ $? -eq 0 ]]; then
      echo "Powerlevel10k configuration file created successfully."
    else
      echo "Failed to create Powerlevel10k configuration file. Please check your permissions."
      exit 1
    fi
  fi
}

clone_powerlevel10k
install_powerlevel10k
applyP10kTheme
