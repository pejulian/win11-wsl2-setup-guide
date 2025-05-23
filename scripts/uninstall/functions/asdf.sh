#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstalling asdf"

echo "🔧 Removing asdf from PATH"
if [[ -f "$ZSHRC_FILE" ]]; then
    remove_from_shell_config "$ZSHRC_FILE" "$ASDF_DIR"
    remove_block_if_exists "$ASDF_CONFIG_BLOCK" "$ZSHRC_FILE"
fi

echo "🔧 Removing asdf from system"
if command -v brew >/dev/null 2>&1; then
    brew uninstall --ignore-dependencies --force asdf 
fi

echo "🔧 Removing asdf global tool versions spec file from $HOME"
if [[ -f "$HOME/.tool-versions" ]]; then
    rm -rf "$HOME/.tool-versions"
fi

echo "🔧 Removing asdf directories and configuration files"
[[ -d "$HOME/.config/asdf" ]] && rm -rf "$HOME/.config/asdf"
[[ -d "$HOME/.local/share/asdf" ]] && rm -rf "$HOME/.local/share/asdf"
[[ -d "$HOME/.cache/asdf" ]] && rm -rf "$HOME/.cache/asdf"
[[ -d "$ASDF_DIR" ]] && rm -rf "$ASDF_DIR"
[[ -f "$HOME/.asdfrc" ]] && rm -rf "$HOME/.asdfrc"
[[ -f "$HOME/.tool-versions" ]] && rm -rf "$HOME/.tool-versions"
[[ -f "$HOME/.asdf" ]] && rm -rf "$HOME/.asdf"

echo "✅ asdf uninstalled"
