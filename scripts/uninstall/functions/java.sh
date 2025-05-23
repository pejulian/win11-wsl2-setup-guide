#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔧 Uninstalling Java"

# Ensure the Java plugin is installed
if ! asdf plugin list | grep -q '^java$'; then
    echo "⚠️ Java plugin not installed. Nothing to uninstall."
else
    asdf list java | sed 's/^[* ]*//' | while read -r version; do
        echo "🔧 Uninstalling java $version"
        asdf uninstall java "$version"
    done

    asdf plugin remove java
    asdf reshim
fi

echo "🔧 Removing Java directories"
[[ -d "$HOME/.asdf/installs/java" ]] && rm -rf "$HOME/.asdf/installs/java"
[[ -d "$HOME/.asdf/plugins/java" ]] && rm -rf "$HOME/.asdf/plugins/java"
[[ -d "$HOME/.java" ]] && rm -f "$HOME/.java"
[[ -d "$HOME/.gradle" ]] && rm -f "$HOME/.gradle"
[[ -d "$HOME/.ivy2" ]] && rm -f "$HOME/.ivy2"

echo "✅ Java uninstalled"