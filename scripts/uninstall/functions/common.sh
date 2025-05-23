#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstalling common toolkit"

if command -v asdf >/dev/null 2>&1; then
    if asdf plugin list jq | grep -q "^jq$"; then
        asdf list jq | sed 's/^[* ]*//' | while read -r version; do
            echo "🔧 Uninstalling jq $version"
            asdf uninstall jq "$version"
        done

        asdf plugin remove jq
        asdf reshim
    fi

    if asdf plugin list peco | grep -q "^peco$"; then
        asdf list peco | sed 's/^[* ]*//' | while read -r version; do
            echo "🔧 Uninstalling peco $version"
            asdf uninstall peco "$version"
        done

        asdf plugin remove peco
        asdf reshim
    fi

    if asdf plugin list ghq | grep -q "^ghq$"; then
        asdf list ghq | sed 's/^[* ]*//' | while read -r version; do
            echo "🔧 Uninstalling ghq $version"
            asdf uninstall ghq "$version"
        done

        asdf plugin remove ghq
        asdf reshim
    fi
fi

echo "🔧 Removing tool directories and configuration files"
[[ -d "$HOME/.asdf/installs/jq" ]] && rm -rf "$HOME/.asdf/installs/jq"
[[ -d "$HOME/.asdf/installs/peco" ]] && rm -rf "$HOME/.asdf/installs/peco"
[[ -d "$HOME/.asdf/installs/ghq" ]] && rm -rf "$HOME/.asdf/installs/ghq"
[[ -d "$HOME/.config/jq" ]] && rm -rf "$HOME/.config/jq"
[[ -d "$HOME/.config/peco" ]] && rm -rf "$HOME/.config/peco"
[[ -d "$HOME/.config/ghq" ]] && rm -rf "$HOME/.config/ghq"
[[ -d "$HOME/.local/share/jq" ]] && rm -rf "$HOME/.local/share/jq"
[[ -d "$HOME/.local/share/peco" ]] && rm -rf "$HOME/.local/share/peco"
[[ -d "$HOME/.local/share/ghq" ]] && rm -rf "$HOME/.local/share/ghq"
[[ -d "$HOME/.local/bin/jq" ]] && rm -rf "$HOME/.local/bin/jq"
[[ -d "$HOME/.local/bin/peco" ]] && rm -rf "$HOME/.local/bin/peco"
[[ -d "$HOME/.local/bin/ghq" ]] && rm -rf "$HOME/.local/bin/ghq"

echo "✅ common toolkit uninstalled"
