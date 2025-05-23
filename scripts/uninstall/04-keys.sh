#!/usr/bin/env zsh

set -euo pipefail

# ===================================
# Load commons
# ===================================
source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🧹 Removing SSH and GPG setup..."

# Derive values
email=$(powershell.exe -Command '[string]::Format("{0}@{1}.dk", $env:USERNAME.ToLower(), $env:USERDOMAIN.ToLower())' | tr -d '\r')
echo "Using email: $email"

user=$(powershell.exe -Command '[string]::Format("{0}", $env:USERNAME.ToLower())' | tr -d '\r')
echo "Using user: $user"

ssh_key_file="$HOME/.ssh/id_ed25519_${user}"

### === Remove SSH Keys === ###
if [[ -f "$ssh_key_file" || -f "${ssh_key_file}.pub" ]]; then
  echo "🗑 Deleting SSH keys..."
  rm -f "$ssh_key_file" "${ssh_key_file}.pub"
else
  echo "✅ No SSH keys found to delete."
fi

### === Clean up ~/.ssh/config === ###
if [[ -f "$HOME/.ssh/config" ]]; then
  echo "✂️ Cleaning up SSH config..."
  rm -rf ~/.ssh/config
  echo "🧹 Removed SSH config"
else
  echo "✅ No ~/.ssh/config found"
fi

### === Delete GPG Key === ###
if command -v gpg >/dev/null 2>&1 && command -v awk >/dev/null 2>&1; then
    echo "🔍 Checking for GPG keys..."

    fingerprints=$(gpg --list-keys --with-colons "$email" 2>/dev/null | awk -F: '/^fpr:/ { print $10 }' || true)

    if [[ -z "$fingerprints" ]]; then
        echo "❌ No GPG key found for $email"
    else
        for fpr in $fingerprints; do
            echo "🔒 Deleting GPG key with fingerprint: $fpr"
            gpg --batch --yes --delete-secret-keys "$fpr" 2>/dev/null || true
            gpg --batch --yes --delete-keys "$fpr" 2>/dev/null || true
            echo "🗑️ Deleted GPG key with fingerprint: $fpr"
        done
    fi
fi

### === Unset Git Config === ###
if command -v git >/dev/null 2>&1; then
    echo "🔍 Checking for git config..."
    if git config --global --get user.signingkey >/dev/null 2>&1; then
        echo "🔧 Unsetting git signing key..."
        git config --global --unset user.signingkey
    else
        echo "✅ No git signing key found."
    fi

    if git config --global --get commit.gpgsign >/dev/null 2>&1; then
        echo "🔧 Unsetting git commit signing..."
        git config --global --unset commit.gpgsign
    else
        echo "✅ No git commit signing found."
    fi
else
    echo "❌ Git not found! Please install Git and rerun the script."
fi

if [[ -d "$HOME/.gnupg" ]]; then
    echo "🗑️ Deleting GPG home directory..."
    rm -rf "$HOME/.gnupg"
else
    echo "✅ No GPG home directory found to delete."
fi

echo "" echo "✅ Cleanup complete!"
 
