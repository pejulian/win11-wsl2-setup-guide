#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔧 Installing Java"

# Ensure the Java plugin is installed
if ! asdf plugin list | grep -q '^java$'; then
  asdf plugin add java
fi

# Install the latest available OpenJDK version
# LATEST_JAVA_VERSION="$(asdf list all java | grep '^openjdk-' | grep -E '^\S+$' | sort -V | tail -n 1)"

# if [[ -z "$LATEST_JAVA_VERSION" ]]; then
  # echo "❌ Could not find any OpenJDK versions via asdf."
  # exit 0
# fi

# echo "➡️ Installing latest OpenJDK: $LATEST_JAVA_VERSION"
# asdf install java "$LATEST_JAVA_VERSION"

# Install the version of openjdk that is used by Bloomrich CMS (Hippo)
echo "➡️ Installing OpenJDK 17.0.2 (used by Bloomrich CMS)"
asdf install java "openjdk-17.0.2"

# Set it globally (optional)
asdf set -u java "openjdk-17.0.2"

# Set JAVA_HOME
JAVA_HOME_PATH="$(asdf where java)"
export JAVA_HOME="$JAVA_HOME_PATH"
export PATH="$JAVA_HOME/bin:$PATH"

add_block_if_missing "$JAVA_CONFIG_BLOCK" "$ZSHRC_FILE"

echo "🎉 Installed java with version: $(java -version 2>&1 | head -n 1)"
