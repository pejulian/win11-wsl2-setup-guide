#!/usr/bin/env zsh

set -euo pipefail

# ===================================
# Load commons
# ===================================
source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔐 Setting up your SSH and GPG keys for $GITHUB_HOST."

echo -n "📛 Enter the email used to sign in to your $GITHUB_HOST account: "
read -r email

echo -n "📛 Enter your name (this will be shown on commit signatures): "
read -r name

# Sanitize email for use in filename
ssh_user=$(echo "$email" | cut -d'@' -f1)
ssh_key_file="$HOME/.ssh/id_ed25519_${ssh_user}"

# Create SSH key if it doesn't exist
if [ -f "$ssh_key_file" ]; then
  echo "✅ SSH key already exists: $ssh_key_file"
else
  echo "🛠 Generating a new SSH key..."
  ssh-keygen -t ed25519 -C "$email" -f "$ssh_key_file" -N ""
  eval "$(ssh-agent -s)"
  ssh-add "$ssh_key_file"
fi

# Add to SSH config
ssh_config_entry="Host $GITHUB_HOST 
  HostName $GITHUB_HOST
  User $user
  IdentityFile $ssh_key_file
  IdentitiesOnly yes"

# Append to ~/.ssh/config if not already present
mkdir -p ~/.ssh
touch ~/.ssh/config
if ! grep -q "IdentityFile $ssh_key_file" ~/.ssh/config; then
  echo -e "\n# GitHub config for $email\n$ssh_config_entry" >> ~/.ssh/config
  echo "📝 Added SSH config for $GITHUB_HOST using key: $ssh_key_file"
else
  echo "✅ SSH config for this key already exists."
fi
 
### === GPG Key Generation === ###
echo "🧪 Checking for GPG..."
if ! command -v gpg >/dev/null; then
  echo "❌ gpg not found! Please install GnuPG and rerun the script."
  exit 1
fi

cat > gpg_batch <<EOF
%no-protection
Key-Type: eddsa
Key-Curve: ed25519
Key-Length: 2048
Subkey-Type: eddsa
Subkey-Curve: ed25519
Subkey-Length: 2048
Name-Real: ${name}
Name-Email: ${email}
Expire-Date: 0
%commit
EOF

echo ""
echo "🛠 Generating a GPG key (for commit signing)..."
gpg --batch --generate-key gpg_batch

rm -rf gpg_batch

echo ""
echo "🔍 Getting GPG key ID..."
gpg_key_id=$(gpg --list-secret-keys --keyid-format=long "$email" | grep sec | awk '{print $2}' | cut -d'/' -f2 | head -n1)

if [ -z "$gpg_key_id" ]; then
  echo "❌ Failed to find GPG key. Aborting."
  exit 1
fi

### === Git Config Setup === ###
echo ""
echo "📝 Updating your git config to sign commits by default..."
git config --global user.signingkey "$gpg_key_id"
git config --global commit.gpgsign true
git config --global user.email "$email"
git config --global user.name "$name"

### === Final Output === ###
echo ""
echo "🎉 All done!"

echo ""
echo "🔑 Add this SSH key to GitHub:"
echo ""
cat "${ssh_key_file}.pub"
echo ""
echo "👉 https://$GITHUB_HOST/settings/keys"

echo ""
echo "🔏 Add this GPG key to GitHub:"
echo ""
gpg --armor --export "$gpg_key_id"
echo ""
echo "👉 https://$GITHUB_HOST/settings/keys (same page, scroll to GPG section)"

echo ""
echo "❗Make sure you have set the SSH and GPG keys in github."
echo ""
echo "🧪 Test your setup (AFTER adding the above):"
echo "  ssh -T git@$GITHUB_HOST"
echo "  git commit -S -m 'your signed commit message'"
echo ""

