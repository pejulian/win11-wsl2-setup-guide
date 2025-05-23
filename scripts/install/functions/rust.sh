#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔧 Installing Rust"
asdf plugin add rust

# Get the latest rust version
LATEST_RUST=$(asdf list all rust \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
  | tail -1)

echo "📦 Latest rust version: $LATEST_RUST"


asdf install rust "$LATEST_RUST"
asdf set -u rust "$LATEST_RUST"
echo "🎉 Installed rust with version: $(rustc --version)"

if [[ ! -f "$HOME/.cargo/config.toml" ]]; then
    echo "⚙ Configuring Cargo"
    mkdir -p "$HOME/.cargo"
    echo "$CARGO_TOML_BLOCK" > "$HOME/.cargo/config.toml" 
fi

add_block_if_missing ". $ASDF_DIR/installs/rust/$LATEST_RUST/env" "$ZSHRC_FILE"
