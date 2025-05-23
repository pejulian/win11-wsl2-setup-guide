#!/usr/bin/env zsh

set -euo pipefail

INSTALL_MODE="full"

echo "🚀 Uninstalling development environment..."

sudo find ./scripts/uninstall -type f -name "*.sh" -exec chmod +x {} \;

echo "🚀 Uninstalling theme..."
source ./scripts/uninstall/05-zsh-theme.sh

if [ $? -eq 0 ]; then
  echo "✅ Uninstalled theme."
else
  echo "❌ Failed to uninstall theme."
  exit 1
fi

echo "🚀 Uninstalling keys..."
source ./scripts/uninstall/04-keys.sh

if [ $? -eq 0 ]; then
  echo "✅ Uninstalled keys."
else
  echo "❌ Failed to uninstall keys."
  exit 1
fi

echo "🚀 Uninstalling tools..."
source ./scripts/uninstall/03-tools.sh

if [ $? -eq 0 ]; then
  echo "✅ Uninstalled tools."
else
  echo "❌ Failed to uninstall tools."
  exit 2
fi

echo "🚀 Uninstalling packages..."
source ./scripts/uninstall/02-packages.sh

if [ $? -eq 0 ]; then
  echo "✅ Uninstalled packages."
else
  echo "❌ Failed to uninstall packages."
  exit 3
fi

echo "🚀 Uninstalling shell..."
source ./scripts/uninstall/01-shell.sh

if [ $? -eq 0 ]; then
  echo "✅ Uninstalled shell."
else
  echo "❌ Failed to uninstall shell."
  exit 4
fi

echo "✅ Uninstalled development environment... please close this terminal and open a new one."

