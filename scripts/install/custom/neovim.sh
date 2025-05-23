#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

# Install Neovim using Linuxbrew
install_neovim() {
    if command -v nvim &>/dev/null; then
        echo "Neovim is already installed."
        return 0
    fi

    echo "Installing additional tooling for Neovim..."
    brew install ripgrep fd fzf bat exa git-delta

    add_block_if_missing "$

    echo "Installing Neovim..."
    brew install neovim

    if ! command -v nvim &>/dev/null; then
        echo "Neovim installation failed."
        return 1
    fi

    echo "Installed Neovim version: $(nvim --version | head -n 1 | cut -d ' ' -f 2)"
}

# Install extensions for Neovim integration in Visual Studio Code
install_vscode_extensions() {
    # Determine the Windows username using PowerShell
    WINDOWS_USERNAME=$(powershell.exe -NoProfile -Command "[System.Environment]::UserName" | tr -d '\r')

    if [ -z "$WINDOWS_USERNAME" ]; then
        echo "Failed to determine Windows username. Please check your PowerShell configuration."
        exit 1
    fi

    # Define possible Visual Studio Code paths
    USER_VSCODE_PATH="/mnt/c/Users/$WINDOWS_USERNAME/AppData/Local/Programs/Microsoft VS Code/bin/code"
    SYSTEM_VSCODE_PATH="/mnt/c/Program Files/Microsoft VS Code/bin/code"

    # Check if Visual Studio Code is installed (user or system)
    if command -v "$USER_VSCODE_PATH" &>/dev/null; then
        VSCODE_PATH="$USER_VSCODE_PATH"
    elif command -v "$SYSTEM_VSCODE_PATH" &>/dev/null; then
        VSCODE_PATH="$SYSTEM_VSCODE_PATH"
    else
        echo "Visual Studio Code is not installed on Windows. Please install it first."
        exit 1
    fi

    # Only install extensions if they are not already installed
    if code --list-extensions | grep -q "asvetliakov.vscode-neovim"; then
        echo "Neovim extension is already installed in Visual Studio Code."
    else
        echo "Installing Neovim extension for Visual Studio Code..."
        "$VSCODE_PATH" --install-extension asvetliakov.vscode-neovim --force
    fi
}

configure_vscode_neovim_settings() {
    # Create the .config/neovim directory and init.lua file if it doesn't exist
    if [ ! -d ~/.config/nvim ]; then
        echo "Creating Neovim configuration directory..."
        mkdir -p ~/.config/nvim
    fi

    echo "Creating Neovim init.lua file..."
    cp -r ./scripts/install/custom/.config/nvim/* ~/.config/nvim/
    
    echo "Neovim configuration directory and init.lua file created."

    # Check if the Neovim extension is installed
    if ! code --list-extensions | grep -q "asvetliakov.vscode-neovim"; then
        echo "Neovim extension is not installed in Visual Studio Code."
        return 1
    fi

    # Use which nvim to get path to nvim and set it in settings.json
    NVIM_PATH=$(which nvim)
    WINDOWS_VSCODE_SETTINGS_DIR="/mnt/c/Users/$WINDOWS_USERNAME/AppData/Roaming/Code/User"
    WINDOWS_VSCODE_SETTINGS_FILE="$WINDOWS_VSCODE_SETTINGS_DIR/settings.json"
    mkdir -p "$WINDOWS_VSCODE_SETTINGS_DIR"
    if [ ! -f "$WINDOWS_VSCODE_SETTINGS_FILE" ]; then
        echo "{}" > "$WINDOWS_VSCODE_SETTINGS_FILE"
    fi

    echo "Configuring Neovim integration in Visual Studio Code..."

    # Set the neovimExecutablePathsLinux and useWSL setting so that neovim can work in WSL
    jq '. + {
        "editor.lineNumbers": "relative",
        "vscode-neovim.neovimExecutablePaths.linux": "'$NVIM_PATH'",
        "vscode-neovim.useWSL": true,
        "vscode-neovim.wslDistribution": "Ubuntu-20.04",
        "vscode-neovim.neovimInitVimPaths.linux": "'$HOME/.config/nvim/init.lua'",
        "extensions.experimental.affinity": {
            "asvetliakov.vscode-neovim": 1
        }
    }' "$WINDOWS_VSCODE_SETTINGS_FILE" > "$WINDOWS_VSCODE_SETTINGS_FILE.tmp" && mv "$WINDOWS_VSCODE_SETTINGS_FILE.tmp" "$WINDOWS_VSCODE_SETTINGS_FILE"

    echo "Neovim integration configured successfully in Visual Studio Code."
}

configure_vscode_neovim_keybindings() {
    WINDOWS_VSCODE_KEYBINDINGS_DIR="/mnt/c/Users/$WINDOWS_USERNAME/AppData/Roaming/Code/User"
    WINDOWS_VSCODE_KEYBINDINGS_FILE="$WINDOWS_VSCODE_KEYBINDINGS_DIR/keybindings.json"
    mkdir -p "$WINDOWS_VSCODE_KEYBINDINGS_DIR"
    if [ ! -f "$WINDOWS_VSCODE_KEYBINDINGS_FILE" ]; then
        echo "[]" > "$WINDOWS_VSCODE_KEYBINDINGS_FILE"
    fi

    node -e "
        const fs = require('fs');
        const f = '$WINDOWS_VSCODE_KEYBINDINGS_FILE';
        const data = fs.readFileSync(f, 'utf-8');
        const json = eval('(' + data + ')'); // Dangerous for general use, OK for keybindings.json

        if (!json.some(k => k.key === 'ctrl+b')) {
            json.push({ 'key': 'ctrl+b', 'command': '-workbench.action.toggleSidebarVisibility' });
        }
 
      fs.writeFileSync('$WINDOWS_VSCODE_KEYBINDINGS_FILE', JSON.stringify(json, undefined, 4));
    "
}

install_neovim
install_vscode_extensions
configure_vscode_neovim_settings
configure_vscode_neovim_keybindings