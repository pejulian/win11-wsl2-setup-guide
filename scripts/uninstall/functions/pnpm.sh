#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstalling pnpm"

if command -v asdf >/dev/null 2>&1; then
    if asdf plugin list pnpm | grep -q "^pnpm$"; then
        echo "🔧 Uninstalling pnpm"
        asdf list pnpm | sed 's/^[* ]*//' | while read -r version; do
            echo "🔧 Uninstalling pnpm $version"
            asdf uninstall pnpm "$version"
        done
        asdf plugin remove pnpm
    fi
fi

echo "🔧 Removing pnpm directories and configuration files"
[[ -d "$HOME/.pnpm" ]] && rm -rf "$HOME/.pnpm"
[[ -d "$HOME/.config/pnpm" ]] && rm -rf "$HOME/.config/pnpm"
[[ -d "$HOME/.cache/pnpm" ]] && rm -rf "$HOME/.cache/pnpm"
[[ -d "$HOME/.asdf/installs/pnpm" ]] && rm -rf "$HOME/.asdf/installs/pnpm"
[[ -d "$HOME/.asdf/plugins/pnpm" ]] && rm -rf "$HOME/.asdf/plugins/pnpm"
[[ -f "$HOME/.pnpmfile.cjs" ]] && rm -f "$HOME/.pnpmfile.cjs"

echo "✅ Uninstalled pnpm"
