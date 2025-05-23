#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🧹 Uninstalling Google Chrome"

# Remove Google Chrome package
sudo apt-get remove -y google-chrome-stable || true

# Remove the Chrome repository
if [[ -f /etc/apt/sources.list.d/google-chrome.list ]]; then
    echo "🔧 Removing Google Chrome repository"
    sudo rm -f /etc/apt/sources.list.d/google-chrome.list
fi

# Remove the GPG key used for signing
if [[ -f /etc/apt/keyrings/google-chrome.gpg ]]; then
    echo "🔧 Removing Google Chrome GPG key"
    sudo rm -f /etc/apt/keyrings/google-chrome.gpg
fi

if [[ -f /usr/share/keyrings/google-chrome.gpg ]]; then
    echo "🔧 Removing Google Chrome GPG key"
    sudo rm -f /usr/share/keyrings/google-chrome.gpg
fi

# Clean up
sudo apt-get autoremove -y
sudo apt-get clean

echo "✅ Google Chrome has been removed"
