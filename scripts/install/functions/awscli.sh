#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔧 Installing AWS CLI"
asdf plugin add awscli
asdf install awscli latest
asdf set -u awscli latest
echo "🎉 Installed awscli with version: $(aws --version)"
