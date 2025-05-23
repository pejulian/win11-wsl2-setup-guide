#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Cleaning up npm"

if command -v npm >/dev/null 2>&1; then
   echo "🔧 Uninstalling node-gyp"
   npm uninstall -g node-gyp
fi

echo "🔧 Removing npm config from $ZSHRC_FILE"
if [ -f "$ZSHRC_FILE" ]; then
   remove_block_if_exists "$NPM_CONFIG_BLOCK" "$ZSHRC_FILE"
   remove_block_if_exists "$NVM_HOOK_BLOCK" "$ZSHRC_FILE"
fi

if command -v npm >/dev/null 2>&1; then
   echo "🔧 Removing npm cache"
   npm cache clean --force
fi

echo "🔧 Removing npm directories and configuration files"
[[ -f "$NPMRC_FILE" ]] && rm -rf "$NPMRC_FILE"
[[ -f "$HOME/.nvmrc" ]] && rm -rf "$HOME/.nvmrc"
[[ -d "$HOME/.npm" ]] && rm -rf "$HOME/.npm"
[[ -d "$HOME/.node_modules" ]] && rm -rf "$HOME/.node_modules"
[[ -d "$HOME/.config/npm" ]] && rm -rf "$HOME/.config/npm"
[[ -d "$HOME/.node-gyp" ]] && rm -rf "$HOME/.node-gyp"
[[ -d "$HOME/.cache/node-gyp" ]] && rm -rf "$HOME/.cache/node-gyp"
[[ -d "$HOME/node-gyp-test" ]] && rm -rf "$HOME/node-gyp-test"

# Remove node and npm from system bin paths (only if they exist)
[[ -f "/usr/local/bin/node" ]] && sudo rm -f /usr/local/bin/node
[[ -f "/usr/local/bin/npm" ]] && sudo rm -f /usr/local/bin/npm
[[ -f "/usr/bin/node" ]] && sudo rm -f /usr/bin/node
[[ -f "/usr/bin/npm" ]] && sudo rm -f /usr/bin/npm

# Remove global Node.js directories (only if they exist)
[[ -d "/usr/local/lib/node_modules" ]] && sudo rm -rf /usr/local/lib/node_modules
[[ -d "/usr/lib/node_modules" ]] && sudo rm -rf /usr/lib/node_modules
[[ -d "/opt/nodejs" ]] && sudo rm -rf /opt/nodejs
[[ -d "/lib/node_modules" ]] && sudo rm -rf /lib/node_modules
[[ -d "/lib/node" ]] && sudo rm -rf /lib/node

echo "✅ Uninstalled npm"

echo "⚙ Uninstalling nvm"

# Uninstall all installed Node.js versions
if command -v nvm >/dev/null 2>&1; then
   for version in "${NODE_VERSIONS[@]}"; do
       echo "🔧 Uninstalling Node.js $version"
       nvm uninstall "$version"
   done
fi

# Remove NVM from PATH
# Remove NVM initialization from shell config
echo "🔧 Removing nvm from PATH"
if [[ -f "$ZSHRC_FILE" ]]; then
   remove_from_shell_config "$ZSHRC_FILE" "$NVM_DIR"
fi

# Remove NVM from system
echo "🔧 Removing nvm directories and configuration files"
[[ -d "$NVM_DIR" ]] && rm -rf "$NVM_DIR"
[[ -f "$HOME/.nvmrc" ]] && rm -rf "$HOME/.nvmrc"

echo "✅ Uninstalled nvm"
