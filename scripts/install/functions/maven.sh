#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔧 Installing maven"

# Ensure the Java plugin is installed
if ! asdf plugin list | grep -q '^maven$'; then
  asdf plugin add maven
fi

# Get all available Maven versions
ALL_VERSIONS=$(asdf list all maven)

# Find the latest stable version
LATEST_STABLE_VERSION=$(echo "$ALL_VERSIONS" |
  grep -vE '(alpha|beta|rc|RC|ALPHA|BETA|M\d)' | # skip alpha, beta, rc, milestones
  grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' |           # match only X.Y.Z
  sort -V |
  tail -n1
)

if [[ -z "$LATEST_STABLE_VERSION" ]]; then
  echo "❌ Could not find a stable maven version to install via asdf."
  exit 0
fi

echo "Latest stable maven version: $LATEST_STABLE_VERSION"

# Install it
asdf install maven "$LATEST_STABLE_VERSION"
asdf set -u maven "$LATEST_STABLE_VERSION"

echo "⚙ Configuring maven"

mkdir -p "$MAVEN_DIR"

echo $MAVEN_FLAGS > "$HOME/.mavenrc"

MAVEN_HOME_PATH="$(asdf where maven)"
export MAVEN_HOME="$MAVEN_HOME_PATH"
export PATH="$MAVEN_HOME/bin:$PATH"

add_block_if_missing "$MAVEN_CONFIG_BLOCK" "$ZSHRC_FILE"

echo "🎉 Installed maven with version: $(mvn -v)"
