#!/usr/bin/env bash

set -e

# ===================================
# Load commons
# ===================================
source ./scripts/common/variables.sh

update_system() {
    echo "⚙ Updating system"
    sudo apt update
    sudo apt upgrade -y
    sudo apt install build-essential software-properties-common -y
    echo "✅ Done updating system" 
}

setup_zsh() {
    echo "⚙ Installing ZSH"
    sudo apt install zsh -y

    echo "🔧 Installing oh-my-zsh"
    # Setup ohmyzsh only if .oh-my-zsh directory does not exist
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "🎉 oh-my-zsh already installed!"
    else
        sh -c "$(curl -fsSL $OHMYZSH_INTALL_PATH)" "" --unattended
    fi

    ZSH_PATH=$(command -v zsh)

    while true; do
        if chsh -s "$ZSH_PATH"; then
            echo "🔧 Default shell changed to ZSH"
            break
        else
            echo "🤯 Failed to change default shell to ZSH. Retrying..."
            sleep 2
        fi
    done

    echo "✅ ZSH has been installed" 
}

configure_git_curl_wget() {
    echo "⚙ Configuring git, curl and wget"

    echo "🔧 Updating ~/.curlrc to increase connect timeout ..."
    if grep -q "^connect-timeout *= *" "$CURLRC_FILE" 2>/dev/null; then
      # Update existing line
      sed -i "s|^connect-timeout *=.*|connect-timeout = 30|" "$CURLRC_FILE"
    else
      # Append new line
      echo "connect-timeout = 30" >> "$CURLRC_FILE"
    fi

    echo "🔧 Updating ~/.curlrc to increase transfer max time ..."
    if grep -q "^max-time *= *" "$CURLRC_FILE" 2>/dev/null; then
      # Update existing line
      sed -i "s|^max-time *=.*|max-time = 300|" "$CURLRC_FILE"
    else
      # Append new line
      echo "max-time = 300" >> "$CURLRC_FILE"
    fi

    echo "🔧 Updating ~/.curlrc to ensure curl only uses ipv4..."
    if ! grep -q "^\s*--ipv4\s*$" "$CURLRC_FILE"; then
        echo "--ipv4" >> "$CURLRC_FILE"
    fi

    echo "🔧 Updating ~/.wgetrc to increase timeouts..."
    if grep -q "^dns-timeout *= *" "$WGETRC_FILE" 2>/dev/null; then
      # Update existing line
      sed -i "s|^dns-timeout *=.*|dns-timeout = 30|" "$WGETRC_FILE"
    else
      # Append new line
      echo "dns-timeout = 15" >> "$WGETRC_FILE"
    fi

    if grep -q "^connect-timeout *= *" "$WGETRC_FILE" 2>/dev/null; then
      # Update existing line
      sed -i "s|^connect-timeout *=.*|connect-timeout = 30|" "$WGETRC_FILE"
    else
      # Append new line
      echo "connect-timeout = 15" >> "$WGETRC_FILE"
    fi
    
    if grep -q "^read-timeout *= *" "$WGETRC_FILE" 2>/dev/null; then
      # Update existing line
      sed -i "s|^read-timeout *=.*|read-timeout = 300|" "$WGETRC_FILE"
    else
      # Append new line
      echo "read-timeout = 60" >> "$WGETRC_FILE"
    fi

    if grep -q "^inet4_only *= *" "$WGETRC_FILE" 2>/dev/null; then
      # Update existing line
      sed -i "s|^inet4_only *=.*|inet4_only = on|" "$WGETRC_FILE"
    else
      # Append new line
      echo "inet4_only = on" >> "$WGETRC_FILE"
    fi
}

update_system
configure_git_curl_wget
setup_zsh

