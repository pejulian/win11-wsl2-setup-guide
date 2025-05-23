#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔧 Installing Ruby"
asdf plugin add ruby
asdf install ruby latest
asdf set -u ruby latest
echo "🎉 Installed ruby with version: $(ruby --version)"


