#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstall Yarn"

if command -v asdf >/dev/null 2>&1; then
    if asdf plugin list yarn | grep -q "^yarn$"; then
        echo "🔧 Uninstalling Yarn"
        asdf list yarn | sed 's/^[* ]*//' | while read -r version; do
            echo "🔧 Uninstalling yarn $version"
            asdf uninstall yarn "$version"
        done
        asdf plugin remove yarn
    fi
fi

echo "🔧 Removing Yarn directories and configuration files" 
[[ -f "$YARNRC_FILE" ]] && rm -rf "$YARNRC_FILE"
[[ -d "$HOME/.yarn" ]] && rm -rf "$HOME/.yarn"
[[ -d "$HOME/.config/yarn" ]] && rm -rf "$HOME/.config/yarn"
[[ -d "$HOME/.cache/yarn" ]] && rm -rf "$HOME/.cache/yarn"
[[ -d "$HOME/.yarn-cache" ]] && rm -rf "$HOME/.yarn-cache"
[[ -d "$HOME/.asdf/installs/yarn" ]] && rm -rf "$HOME/.asdf/installs/yarn"

echo "✅ Uninstalled Yarn"

