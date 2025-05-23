#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstalling maven"

remove_block_if_exists "$MAVEN_CONFIG_BLOCK" "$ZSHRC_FILE"

if command -v asdf >/dev/null 2>&1; then
    # Check if java plugin is installed
    if ! asdf plugin list | grep -q '^maven$'; then
      echo "⚠️  maven plugin not installed. Nothing to uninstall."
    else
        asdf list maven | sed 's/^[* ]*//' | while read -r version; do
            echo "🔧 Uninstalling maven $version"
            asdf uninstall maven "$version"
        done

        asdf plugin remove maven
        asdf reshim
    fi
fi

echo "🔧 Removing maven directories"
[[ -d "$HOME/.asdf/installs/maven" ]] && rm -rf "$HOME/.asdf/installs/maven"
[[ -d "$HOME/.asdf/plugins/maven" ]] && rm -rf "$HOME/.asdf/plugins/maven"
[[ -d "$MAVEN_DIR" ]] && rm -rf "$MAVEN_DIR"
[[ -d "$HOME/.mvn" ]] && rm -f "$HOME/.mvn"
[[ -f "$HOME/.mavenrc" ]] && rm -f "$HOME/.mavenrc"

echo "✅ maven uninstalled"
