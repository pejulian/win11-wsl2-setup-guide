#!/usr/bin/env zsh

set -euo pipefail

# ===================================
# Load commons
# ===================================
source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

remove_linuxbrew() {
    echo "⚙ Removing linuxbrew"

    if command -v brew >/dev/null 2>&1; then
        echo "🔧 Removing linuxbrew packages"
        if [[ -n "$(brew list --formula)" ]]; then
          brew list --formula | xargs brew uninstall --ignore-dependencies --force
        else
          echo "✅ No Homebrew formulas installed."
        fi
    fi

    echo "🔧 Removing linuxbrew directories"
    sudo rm -rf ~/.linuxbrew /home/linuxbrew/.linuxbrew
    sudo rm -rf ~/.cache/Homebrew ~/.config/homebrew ~/.local/share/homebrew

    if [[ -f "$ZSHRC_FILE" ]]; then
       remove_from_shell_config "$ZSHRC_FILE" "/home/linuxbrew/.linuxbrew/bin"
       remove_from_shell_config "$ZSHRC_FILE" "/home/linuxbrew/.linuxbrew/sbin"
       remove_from_shell_config "$ZSHRC_FILE" 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    fi

    echo "✅ linuxbrew removed"
}

remove_zsh_configurations() {
    echo "⚙ Removing zsh configurations"

    if [[ -f "$HOME/.zcompdump" ]]; then
        sudo find "$HOME" -maxdepth 1 -name ".zcompdump*" -exec rm -f {} \;
    fi

    if [[ -f "$ZSHRC_FILE" ]]; then
        remove_block_if_exists "$ZSH_COMPINIT_BLOCK" "$ZSHRC_FILE"
        remove_block_if_exists "$(generate_modbanner_block)" "$ZSHRC_FILE"
        remove_block_if_exists "$COMPILER_AND_LINKER_FLAGS_BLOCK" "$ZSHRC_FILE"
        remove_block_if_exists "$LD_LIBRARY_PATH_BLOCK" "$ZSHRC_FILE"
        remove_block_if_exists "$GPG_SSH_BLOCK" "$ZSHRC_FILE"
        remove_block_if_exists "$ZSH_PLUGIN_INIT_BLOCK" "$ZSHRC_FILE"
    fi

    echo "✅ removed zsh configurations"
}

remove_linuxbrew
remove_zsh_configurations



