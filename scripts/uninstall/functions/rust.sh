#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstalling Rust"

if command -v rustup >/dev/null 2>&1; then
    rustup self uninstall -y >/dev/null 2>&1 || true
fi

if command -v asdf >/dev/null 2>&1; then
    if asdf plugin list rust | grep -q "^rust$"; then
        asdf list rust | sed 's/^[* ]*//' | while read -r version; do
            echo "🔧 Uninstalling rust $version"
            asdf uninstall rust "$version"
            remove_block_if_exists ". $ASDF_DIR/installs/rust/$version/env" "$ZSHRC_FILE"
        done

        asdf plugin remove rust
        asdf reshim
    fi
fi

echo "🔧 Removing Rust directories and configuration files"
[[ -d "$HOME/.cargo" ]] && rm -rf "$HOME/.cargo"
[[ -d "$HOME/.rustup" ]] && rm -rf "$HOME/.rustup"
[[ -d "$HOME/.asdf/installs/rust" ]] && rm -rf "$HOME/.asdf/installs/rust"
[[ -d "$HOME/.asdf/plugins/rust" ]] && rm -rf "$HOME/.asdf/plugins/rust"
[[ -d "$HOME/.config/rust" ]] && rm -rf "$HOME/.config/rust"
[[ -d "$HOME/.cache/rust" ]] && rm -rf "$HOME/.cache/rust"
[[ -d "$HOME/.local/share/cargo" ]] && rm -rf "$HOME/.local/share/cargo"
[[ -d "$HOME/.local/share/rustup" ]] && rm -rf "$HOME/.local/share/rustup"

echo "✅ Rust uninstalled"
