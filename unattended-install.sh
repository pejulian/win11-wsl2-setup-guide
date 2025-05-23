#!/usr/bin/env bash

set -e

COMMAND=${1:-}

if [[ -z "$COMMAND" ]]; then
    echo "📦 Choose your VS Code setup type:"
    select INSTALL_TYPE in "Web developer install" "Full install"; do
      case $INSTALL_TYPE in
        "Full install")
          export INSTALL_MODE="full"
          break
          ;;
        "Web developer install")
          export INSTALL_MODE="webdev"
          break
          ;;
        *)
          echo "❌ Invalid choice. Please enter 1 or 2."
          ;;
      esac
    done
fi

sudo find ./scripts/install -type f -name "*.sh" -exec chmod +x {} \;

# Get absolute path to current script
SCRIPT_PATH="$(realpath "$0")"

if ! command -v zsh >/dev/null 2>&1; then
    echo "🚀 Starting unattended installation..."

    echo "🚀 Setting up base shell environment..."
    source ./scripts/install/01-shell.sh

    if [ $? -eq 0 ]; then
        echo "✅ Set up base shell environment."

        if [ -z "${ZSH_VERSION:-}" ]; then
            echo "🚀 Switching to Zsh..."
            export SHELL="$(which zsh)"
            exec env INSTALL_MODE="$INSTALL_MODE" "$(which zsh)" "$SCRIPT_PATH" "packages" "$@"
        fi
    else
      echo "❌ Failed to set up base shell environment."
      exit 1
    fi
else 
    if [ -z "${ZSH_VERSION:-}" ]; then
        exec env INSTALL_MODE="$INSTALL_MODE" "$(which zsh)" "$SCRIPT_PATH" "packages" "$@"
    fi
fi

if [[ "$COMMAND" == "packages" ]]; then
    echo "🚀 Installing packages..."
    source ./scripts/install/02-packages.sh

    if [ $? -eq 0 ]; then
        echo "✅ Set up packages."
        exec env INSTALL_MODE="$INSTALL_MODE" "$(which zsh)" "$SCRIPT_PATH" "tools" "$@"
    else 
        echo "❌ Failed to set up packages."
        exec env INSTALL_MODE="$INSTALL_MODE" "$(which zsh)" "$SCRIPT_PATH" "error" "$@"
    fi
fi

if [[ "$COMMAND" == "tools" ]]; then
    echo "🚀 Installing tools..."
    source ./scripts/install/03-tools.sh

    if [ $? -eq 0 ]; then
        echo "✅ Set up tools."
        exec env INSTALL_MODE="$INSTALL_MODE" "$(which zsh)" "$SCRIPT_PATH" "keys" "$@"
    else
        echo "❌ Failed to set up tools."
        exec env INSTALL_MODE="$INSTALL_MODE" "$(which zsh)" "$SCRIPT_PATH" "error" "$@"
    fi
fi

if [[ $COMMAND == "keys" ]]; then
    echo "🚀 Setting up keys"
    source ./scripts/install/04-keys.sh

    if [ $? -eq 0 ]; then
        echo "✅ Set up keys."
        exec env INSTALL_MODE="$INSTALL_MODE" "$(which zsh)" "$SCRIPT_PATH" "theme" "$@"
    else
        echo "❌ Failed to set up keys."
        exec env INSTALL_MODE="$INSTALL_MODE" "$(which zsh)" "$SCRIPT_PATH" "error" "$@"
    fi
fi

if [[ $COMMAND == "theme" ]]; then
    echo "🚀 Setting up zsh theme"
    source ./scripts/install/05-zsh-theme.sh

    if [ $? -eq 0 ]; then
        echo "✅ Set up zsh theme."
        exec env INSTALL_MODE="$INSTALL_MODE" "$(which zsh)" "$SCRIPT_PATH" "success" "$@"
    else
        echo "❌ Failed to set up zsh theme."
        exec env INSTALL_MODE="$INSTALL_MODE" "$(which zsh)" "$SCRIPT_PATH" "error" "$@"
    fi
fi


if [[ $COMMAND == "success" ]]; then
  echo "✅ Development environment set up!"
  echo ""
  echo "✔ Close and open a new terminal window to apply the changes."
  echo ""
fi

if [[ $COMMAND == "error" ]]; then
  echo "❌ Failed to set up development environment." 
fi
