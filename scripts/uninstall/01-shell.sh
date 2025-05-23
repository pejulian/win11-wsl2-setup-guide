#!/usr/bin/env zsh

set -euo pipefail

# ===================================
# Load commons
# ===================================
source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

remove_ohmyzsh() {
    echo "⚙ Uninstalling Oh My Zsh"
    
    echo "🔧 Changing default shell back to bash"
    BASH_PATH=$(which bash)

    while true; do
        if chsh -s "$BASH_PATH"; then
            echo "🔧 Default shell changed to bash"
            break
        else
            echo "🤯 Failed to change default shell to bash. Retrying..."
            sleep 2
        fi
    done

    echo "🔧 Removing Oh My Zsh"
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        echo "🔧 Removing $HOME/.oh-my-zsh"
        rm -rf $HOME/.oh-my-zsh
    fi

    if [[ -f "$ZSHRC_FILE" ]]; then
        echo "🔧 Removing $ZSHRC_FILE"
        rm "$ZSHRC_FILE"
    fi

    if [[ -f "$ZSHRC_FILE.bak" ]]; then
        echo "🔧 Removing $ZSHRC_FILE.bak"
        rm "$ZSHRC_FILE.bak"
    fi

    if [[ -f "$HOME/.zsh_history" ]]; then
        echo "🔧 Removing $ZSHRC_FILE.bak"
        rm "$HOME/.zsh_history"
    fi

    if [[ -d /usr/share/zsh/functions ]]; then
        echo "🔧 Removing /usr/share/zsh/functions"
        sudo rm -rf /usr/share/zsh/functions
    fi

    if [[ -d ~/.zsh/completions ]]; then
        echo "🔧 Removing ~/.zsh/completions"
        rm -rf ~/.zsh/completions
    fi

    echo "🔧 Removing zsh"
    sudo apt remove --purge zsh -y
    sudo apt autoremove -y

    echo "✅ zsh removed"
}

remove_curl_selfsigned_cert() {
  echo "⚙ Starting cleanup of curl self-signed certificate config..."

  if [[ -f "$CURLRC_FILE" ]]; then
    echo "🔧 Removing $CURLRC_FILE..."
    rm "$CURLRC_FILE"
  fi

  if [[ -f "$CURLRC_FILE.bak" ]]; then
    echo "🔧 Removing $CURLRC_FILE.bak..."
    rm "$CURLRC_FILE.bak"
  fi

  if [[ -f "$WGETRC_FILE" ]]; then
    echo "🔧 Removing $WGETRC_FILE..."
    rm "$WGETRC_FILE"
  fi

  if [[ -f "$WGETRC_FILE.bak" ]]; then
    echo "🔧 Removing $WGETRC_FILE.bak..."
    rm "$WGETRC_FILE.bak"
  fi

  if [[ -f "$HOME/.wget-hsts" ]]; then
    echo "🔧 Removing $HOME/.wget-hsts..."
    rm "$HOME/.wget-hsts"
  fi

  echo "🔧 Removing git config for curl self-signed certificate..."
  if command -v git >/dev/null 2>&1; then
      git config --global --unset http.sslCAInfo || true
      git config --global --unset http.sslVerify || true
  fi

  if [[ -f "$HOME/.gitconfig" ]]; then
      echo "🔧 Deleting $HOME/.gitconfig..."
      rm -f "$HOME/.gitconfig"
  fi

  echo "✅ Curl and wget config to support self-signed certificate removed"
}

remove_curl_selfsigned_cert
remove_ohmyzsh

