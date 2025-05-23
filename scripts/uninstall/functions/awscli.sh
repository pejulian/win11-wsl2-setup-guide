#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstalling AWS CLI"

if command -v asdf >/dev/null 2>&1; then
    if asdf plugin list awscli | grep -q "^awscli$"; then
        asdf list awscli | sed 's/^[* ]*//' | while read -r version; do
            echo "🔧 Uninstalling awscli $version"
            asdf uninstall awscli "$version"
        done

        asdf plugin remove awscli
        asdf reshim
    fi
fi

[[ -d "$HOME/.aws" ]] && rm -rf "$HOME/.aws"
[[ -d "$HOME/.awscli" ]] && rm -rf "$HOME/.awscli"
[[ -d "$HOME/.config/aws" ]] && rm -rf "$HOME/.config/aws"
[[ -d "$HOME/.cache/awscli" ]] && rm -rf "$HOME/.cache/awscli"
[[ -d "$HOME/.cache/aws" ]] && rm -rf "$HOME/.cache/aws"
[[ -d "$HOME/.asdf/installs/awscli" ]] && rm -rf "$HOME/.asdf/installs/awscli"

# Remove system-wide binaries (only if they exist)
[[ -f "/usr/local/bin/aws" ]] && sudo rm -f /usr/local/bin/aws
[[ -f "/usr/bin/aws" ]] && sudo rm -f /usr/bin/aws
[[ -f "/usr/local/bin/aws_completer" ]] && sudo rm -f /usr/local/bin/aws_completer
[[ -f "/usr/bin/aws_completer" ]] && sudo rm -f /usr/bin/aws_completer

# Remove AWS CLI v2 default install directory (zip-based install)
[[ -d "/usr/local/aws-cli" ]] && sudo rm -rf /usr/local/aws-cli

# Remove any stray AWS CLI symlinks or paths in /opt or /lib
[[ -d "/opt/aws" ]] && sudo rm -rf /opt/aws
[[ -d "/lib/aws-cli" ]] && sudo rm -rf /lib/aws-cli

echo "✅ AWS CLI uninstalled"
