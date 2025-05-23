#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Installing asdf"

brew install asdf 

mkdir -p "$ASDF_DIR"
add_block_if_missing "$ASDF_CONFIG_BLOCK" "$ZSHRC_FILE"

cat <<EOF >> ~/.asdfrc
legacy_version_file = yes
always_keep_download = no
EOF

# source asdf into the current session
. "$(brew --prefix asdf)/libexec/asdf.sh"

echo "🎉 Installed asdf with version: $(asdf --version)"
