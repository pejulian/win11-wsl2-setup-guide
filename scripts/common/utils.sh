#!/usr/bin/env zsh

# Function to remove paths from a given file
remove_from_shell_config() {
  local target_file="$1"
  local target_line="$2"

  if [[ -f "$target_file" ]]; then
    if grep -Fxq "$target_line" "$target_file"; then
      echo "🧹 Removing line from $target_file"
      # cp "$target_file" "$target_file.bak"  # Create a backup
      sed -i "/^$(printf '%s' "$target_line" | sed 's/[[\.*^$/]/\\&/g')$/d" "$target_file"
    else
      echo "✅ Line not found in $target_file"
    fi
  else
    echo "File $target_file does not exist"
  fi
}

# Function to append or prepend a block if it's not already present
add_block_if_missing() {
  local block="$1"
  local file="$2"
  local position="${3:-bottom}"  # default to bottom if not specified

  # Create a checksum of the block (normalize whitespace)
  local checksum
  checksum=$(echo "$block" | sha256sum | cut -d ' ' -f 1)

  # Check if the file already contains the block's checksum
  if grep -q "$checksum" "$file" 2>/dev/null; then
    echo "✅ Block already exists in $file"
  else
    local block_with_markers
    block_with_markers=$'\n'"# BEGIN BLOCK [$checksum]"$'\n'"$block"$'\n'"# END BLOCK [$checksum]"$'\n'

    if [[ "$position" == "top" ]]; then
      # Prepend to file
      tmp_file=$(mktemp)
      echo -n "$block_with_markers" > "$tmp_file"
      cat "$file" >> "$tmp_file"
      mv "$tmp_file" "$file"
      echo "🔝 Block added to the top of $file"
    else
      # Append to file
      echo -n "$block_with_markers" >> "$file"
      echo "➕ Block added to the bottom of $file"
    fi
  fi
}
 

# Function to remove a block if it exists
remove_block_if_exists() {
  local block="$1"
  local file="$2"

  # Calculate checksum of the block
  local checksum=$(echo "$block" | sha256sum | cut -d ' ' -f 1)

  # Use sed to delete the block between matching BEGIN/END markers
  if grep -q "$checksum" "$file"; then
    sed -i.bak "/# BEGIN BLOCK \[$checksum\]/,/^# END BLOCK \[$checksum\]/d" "$file"
    echo "🗑️ Removed block from $file (checksum: $checksum)"
  else
    echo "✅ No block found to remove in $file"
  fi
}

# Banner
generate_modbanner_block() {
cat <<'EOF'

if command -v figlet &>/dev/null && command -v lolcat &>/dev/null; then
  figlet "Welcome, $USER!" | lolcat
fi

modbanner() {
  echo -e "\n\e[1;34m============================\e[0m"
  echo -e "\e[1;36m   Your environment 🧭\e[0m"
  echo -e "\e[1;34m============================\e[0m"

  echo -e "\e[1;33m🖥️ Hostname:\e[0m $(hostname)"
  echo -e "\e[1;33m🧠 OS:\e[0m $(uname -srmo)"
  echo -e "\e[1;33m🗓️ OS Version:\e[0m $(lsb_release -rs)"
  echo -e "\e[1;33m🔖 Codename:\e[0m $(lsb_release -cs)"
  echo -e "\e[1;33m🔗 Internal IP:\e[0m $(hostname -I | awk '{print $1}')"
  echo -e "\e[1;33m🌐 External IP:\e[0m $(curl -s https://ifconfig.me || echo 'Unavailable')"
  echo -e "\e[1;33m💻 Shell:\e[0m $SHELL"

  echo -e "\e[1;33m🍺 Homebrew:\e[0m $(brew --version 2>/dev/null || echo 'Not installed')"
  echo -e "\e[1;33m🔢 Asdf:\e[0m $(asdf --version 2>/dev/null || echo 'Not installed')"

  echo -e "\e[1;33m🔧 Git:\e[0m $(git --version 2>/dev/null || echo 'Not installed')"
  echo -e "\e[1;33m🐍 Python:\e[0m $(python --version 2>/dev/null || echo 'Not installed')"
  echo -e "\e[1;33m📦 pipx:\e[0m $(pipx --version 2>/dev/null || echo 'Not installed')"

  if command -v java >/dev/null 2>&1; then
      JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
      echo -e "\e[1;33m☕ Java:\e[0m $JAVA_VERSION"
  fi

  if command -v mvn >/dev/null 2>&1; then
      MAVEN_VERSION=$(mvn -v | grep -oP '^Apache Maven \K[0-9.]+')
      echo -e "\e[1;33m📦 Maven:\e[0m $MAVEN_VERSION"
  fi

  echo -e "\e[1;33m☁️ AWS CLI:\e[0m $(aws --version 2>/dev/null || echo 'Not installed')"

  if command -v rustc >/dev/null 2>&1; then
      echo -e "\e[1;33m🦀 Rust:\e[0m $(rustc --version 2>/dev/null || echo 'Not installed')"
  fi

  if command -v ruby >/dev/null 2>&1; then
      echo -e "\e[1;33m💎 Ruby:\e[0m $(ruby --version 2>/dev/null || echo 'Not installed')"
  fi

  echo -e "\e[1;33m🌿 NVM:\e[0m $(nvm --version 2>/dev/null || echo 'Not installed')"
  echo -e "\e[1;33m🟩 Node.js:\e[0m $(node -v 2>/dev/null || echo 'Not installed')"
  echo -e "\e[1;33m📦 NPM:\e[0m $(npm --version 2>/dev/null || echo 'Not installed')"
  echo -e "\e[1;33m📦 PNPM:\e[0m $(pnpm --version 2>/dev/null || echo 'Not installed')"
  echo -e "\e[1;33m📦 Yarn:\e[0m $(yarn --version 2>/dev/null || echo 'Not installed')"

  if command -v docker >/dev/null 2>&1; then
      echo -e "\e[1;33m🐳 Docker:\e[0m $(docker --version 2>/dev/null || echo 'Not installed')"
  fi

  echo -e "\e[1;33m🌐 Chrome:\e[0m $(google-chrome --version 2>/dev/null || echo 'Not installed')"

  if command -v code >/dev/null 2>&1; then
      version=$(code --version | head -n 1)
      echo -e "\e[1;33m📝 VS Code:\e[0m $version"
  fi

  echo -e "\n\e[1;35m🔧 Maintained by: Cloud 9 Platform\e[0m"
  echo -e "\e[1;35m📬 Contact: Julian Pereira <ln0@topdanmark.dk>\e[0m"
  echo -e ""
}

modbanner

EOF
 
}

# Add plugins to zshrc
 add_zsh_plugins() {
  local zshrc="$ZSHRC_FILE"
  local plugins_to_add=("$@")

  # Extract existing plugins
  local current_line
  current_line=$(grep '^plugins=' "$zshrc" || echo "plugins=()")

  # Remove 'plugins=(' and ')' to get just the names
  local existing_plugins_str="${current_line#plugins=}"
  existing_plugins_str="${existing_plugins_str#\(}"
  existing_plugins_str="${existing_plugins_str%\)}"

  # Convert to array
  local existing_plugins=()
  for plugin in $existing_plugins_str; do
    existing_plugins+=("$plugin")
  done

  # Merge arrays and deduplicate
  local all_plugins=("${existing_plugins[@]}")
  for plugin in "${plugins_to_add[@]}"; do
    if [[ ! " ${all_plugins[*]} " =~ " $plugin " ]]; then
      all_plugins+=("$plugin")
    fi
  done

  # Rebuild plugins line
  local new_plugin_line="plugins=(${all_plugins[*]})"

  # Replace or add plugins line
  if grep -q '^plugins=' "$zshrc"; then
    sed -i.bak "s/^plugins=.*/$new_plugin_line/" "$zshrc"
  else
    echo -e "\n$new_plugin_line" >> "$zshrc"
  fi

  echo "✅ Plugins updated in $zshrc"
}
 
# Function to set up Zsh plugins
setup_zsh_plugins() {
  local plugin_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

  # Ensure plugin directory exists
  if [ ! -d "$plugin_dir" ]; then
    echo "⚠️ Plugin directory $plugin_dir does not exist. Skipping plugin setup."
    return
  fi

  # Plugin list (name and URL pairs)
  local plugins=(
    "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git"
    "zsh-autocomplete https://github.com/marlonrichert/zsh-autocomplete.git"
    "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
  )

  for plugin_entry in "${plugins[@]}"; do
    local name url
    name=$(echo "$plugin_entry" | awk '{print $1}')
    url=$(echo "$plugin_entry" | awk '{print $2}')
    local plugin_path="$plugin_dir/$name"

    if [ -d "$plugin_path" ]; then
      echo "🧹 Removing existing $name directory..."
      rm -rf "$plugin_path"
    fi

    echo "⬇️  Cloning $name..."
    git clone "$url" "$plugin_path"
  done
}

