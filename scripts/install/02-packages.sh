#!/usr/bin/env zsh

# ===================================
# Load commons
# ===================================
source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

install_linuxbrew() {
    echo "⚙ Installing Linuxbrew"

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL $LINUXBREW_INSTALL_PATH)"
    
    # Set up brew env for current session
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

    # Persist it to shell config
    BREW_ENV='eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
    add_block_if_missing "$BREW_ENV" "$ZSHRC_FILE"

    echo "🎉 Installed Linuxbrew with version: $(brew --version)"
    
    # Increate open file limit in current shell
    ulimit -n 8192

    brew install "${BREW_PACKAGES[@]}"
    
    echo "✅ Essential packages installed via brew"
}

configure_zsh() {
    echo "⚙ Configuring ZSH"

    setup_zsh_plugins 

    if [[ -f "$HOME/.zcompdump" ]]; then
        rm -f "$HOME/.zcompdump"
    fi

    add_block_if_missing "$ZSH_COMPINIT_BLOCK" "$ZSHRC_FILE"
    add_block_if_missing "$(generate_modbanner_block)" "$ZSHRC_FILE"
    add_block_if_missing "$COMPILER_AND_LINKER_FLAGS_BLOCK" "$ZSHRC_FILE"
    add_block_if_missing "$LD_LIBRARY_PATH_BLOCK" "$ZSHRC_FILE"
    add_block_if_missing "$GPG_SSH_BLOCK" "$ZSHRC_FILE"
    add_block_if_missing "$ZSH_PLUGIN_INIT_BLOCK" "$ZSHRC_FILE"

    add_zsh_plugins "${ZSH_PLUGINS[@]}"

    echo "🎉 Configured ZSH with plugins: ${ZSH_PLUGINS[*]}"

    echo "✅ ZSH Configured"
}

install_linuxbrew
configure_zsh
