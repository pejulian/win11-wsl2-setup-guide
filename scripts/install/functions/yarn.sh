#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Configuring Yarn"

# Install Yarn
echo "🔧 Installing Yarn"
asdf plugin add yarn

if ! asdf install yarn latest; then
    echo "🤯 Failed to install yarn latest"
else
    asdf set -u yarn latest
    echo "🎉 Installed yarn with version: $(yarn --version)"
fi

echo "✅ Yarn configured"
