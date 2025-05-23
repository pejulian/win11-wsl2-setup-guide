#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstalling Ruby"

if command -v rbenv >/dev/null 2>&1; then
    rbenv uninstall --force "$(rbenv version-name)"
    rbenv rehash
fi

if command -v asdf >/dev/null 2>&1; then
    if asdf plugin list ruby | grep -q "^ruby$"; then
        asdf list ruby | sed 's/^[* ]*//' | while read -r version; do
            echo "🔧 Uninstalling ruby $version"
            asdf uninstall ruby "$version"
        done

        asdf plugin remove ruby
        asdf reshim
    fi
fi

echo "🔧 Removing Ruby directories"
[[ -d "$HOME/.gem" ]] && rm -rf "$HOME/.gem"
[[ -d "$HOME/.rbenv" ]] && rm -rf "$HOME/.rbenv"
[[ -d "$HOME/.rvm" ]] && rm -rf "$HOME/.rvm"
[[ -d "$HOME/.rubies" ]] && rm -rf "$HOME/.rubies"
[[ -d "$HOME/.bundle" ]] && rm -rf "$HOME/.bundle"
[[ -d "$HOME/.irb" ]] && rm -rf "$HOME/.irb"
[[ -d "$HOME/.pry" ]] && rm -rf "$HOME/.pry"
[[ -f "$HOME/.ruby-version" ]] && rm -rf "$HOME/.ruby-version"
[[ -f "$HOME/.ruby-gemset" ]] && rm -rf "$HOME/.ruby-gemset"
[[ -d "$HOME/.rubocop" ]] && rm -rf "$HOME/.rubocop"
[[ -d "$HOME/.asdf/installs/ruby" ]] && rm -rf "$HOME/.asdf/installs/ruby"
[[ -d "$HOME/.asdf/plugins/ruby" ]] && rm -rf "$HOME/.asdf/plugins/ruby"
[[ -d "$HOME/.config/ruby" ]] && rm -rf "$HOME/.config/ruby"
[[ -d "$HOME/.cache/ruby" ]] && rm -rf "$HOME/.cache/ruby"
[[ -d "$HOME/.local/share/gem" ]] && rm -rf "$HOME/.local/share/gem"

echo "✅ Ruby uninstalled"
