#!/usr/bin/env zsh

# Uninstall Neovim using Linuxbrew
uninstall_neovim() {
    brew uninstall ripgrep fd fzf bat exa git-delta

    echo "Uninstalling Neovim..."

    if ! command -v nvim &>/dev/null; then
        echo "Neovim is not installed."
        return 0
    fi

    brew uninstall neovim

    if command -v nvim &>/dev/null; then
        echo "Neovim uninstallation failed."
        return 1
    fi
    
    echo "Uninstalled Neovim successfully."
}

# Install extensions for Neovim integration in Visual Studio Code
uninstall_vscode_extensions() {
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
        echo "Visual Studio Code is not installed on Windows."
        exit 1
    fi

    if ! "$VSCODE_PATH" --list-extensions | grep -q asvetliakov.vscode-neovim; then
        echo "Neovim extension for Visual Studio Code is not installed."
        return 0
    fi

    "$VSCODE_PATH" --uninstall-extension asvetliakov.vscode-neovim --force
}

remove_vscode_neovim_config() {
    # Determine the Windows username using PowerShell
    WINDOWS_USERNAME=$(powershell.exe -NoProfile -Command "[System.Environment]::UserName" | tr -d '\r')

    if [ -z "$WINDOWS_USERNAME" ]; then
        echo "Failed to determine Windows username. Please check your PowerShell configuration."
        exit 1
    fi

    # Define possible Visual Studio Code settings directory
    WINDOWS_VSCODE_SETTINGS_DIR="/mnt/c/Users/$WINDOWS_USERNAME/AppData/Roaming/Code/User"
    WINDOWS_VSCODE_SETTINGS_FILE="$WINDOWS_VSCODE_SETTINGS_DIR/settings.json"

    if [ -f "$WINDOWS_VSCODE_SETTINGS_FILE" ]; then
        echo "Removing Neovim configuration from Visual Studio Code settings..."

        # First jq operation: Remove Neovim-related settings
        jq 'del(.["editor.lineNumbers"],
                .["vscode-neovim.neovimExecutablePaths.linux"], 
                .["vscode-neovim.useWSL"], 
                .["vscode-neovim.wslDistribution"], 
                .["vscode-neovim.neovimInitVimPaths.linux"])' \
            "$WINDOWS_VSCODE_SETTINGS_FILE" > "$WINDOWS_VSCODE_SETTINGS_FILE.tmp" && mv "$WINDOWS_VSCODE_SETTINGS_FILE.tmp" "$WINDOWS_VSCODE_SETTINGS_FILE"

        # Second jq operation: Handle extensions.experimental.affinity
        jq 'if .extensions.experimental.affinity != null then 
                del(.extensions.experimental.affinity["asvetliakov.vscode-neovim"]) 
                | if (.extensions.experimental.affinity | keys | length) == 0 then del(.extensions.experimental.affinity) else . end 
            else . end' \
            "$WINDOWS_VSCODE_SETTINGS_FILE" > "$WINDOWS_VSCODE_SETTINGS_FILE.tmp" && mv "$WINDOWS_VSCODE_SETTINGS_FILE.tmp" "$WINDOWS_VSCODE_SETTINGS_FILE"
        
        echo "Neovim configuration removed successfully from Visual Studio Code settings."
    else
        echo "Visual Studio Code settings file not found."
    fi
}

remove_vscode_neovim_config
uninstall_vscode_extensions
uninstall_neovim