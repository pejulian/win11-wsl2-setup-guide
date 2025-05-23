#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔧 Installing pnpm"
asdf plugin add pnpm

# Get the latest pnpm version
LATEST_PNPM=$(asdf list all pnpm \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
  | tail -1)

echo "📦 Latest pnpm version: $LATEST_PNPM"

if ! asdf install pnpm "$LATEST_PNPM"; then
    echo "🤯 Failed to install pnpm $LATEST_PNPM"
else
    asdf set -u pnpm "$LATEST_PNPM"
    echo "🎉 Installed pnpm with version: $(pnpm --version)"
fi
