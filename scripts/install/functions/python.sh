#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔧 Installing Python"

# Add library paths manually for python
local LD_LIBRARY_PATH
echo "$LD_LIBRARY_PATH_BLOCK" | while IFS= read -r line; do
  [[ "$line" =~ ^\s*# ]] && continue  # Skip comments
  [[ -z "$line" ]] && continue        # Skip empty lines
  eval "$line"
done

# Add compiler and linker flags for python
echo "$COMPILER_AND_LINKER_FLAGS_BLOCK" | while IFS= read -r line; do
  [[ "$line" =~ ^\s*# ]] && continue  # Skip comments
  [[ -z "$line" ]] && continue        # Skip empty lines
  eval "$line"
done

# export PYTHON_BUILD_HTTP_CLIENT="curl"
# export PYTHON_BUILD_CURL_OPTS="--show-error --location --connect-timeout 60  --max-time 60 --ipv4 --retry 3 --retry-delay 5 --retry-max-time 30"

asdf plugin add python

# Get the latest Python version
PYTHON_VERSION=$(asdf list all python \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' \
  | tail -1)
# PYTHON_VERSION=3.12.10

# Install and set globally
echo "📦 Python version to install: $PYTHON_VERSION"

if ! asdf install python "$PYTHON_VERSION"; then
    echo "🤯 Initial install failed. Reattempting download with different options..."

    export PYTHON_BUILD_HTTP_CLIENT="wget"
    # export PYTHON_BUILD_WGET_OPTS="--timeout=15 --tries=3 --waitretry=2 --retry-connrefused --retry-on-http-error=503"

    asdf install python "$PYTHON_VERSION" || {
        echo "🤯 Failed to install Python $PYTHON_VERSION"
        return 1
    }
fi

asdf set -u python "$PYTHON_VERSION"
echo "🎉 Installed python with version: $(python --version)"

# Install pipx
echo "🔧 Installing pipx"
python -m pip install --user pipx
python -m pipx ensurepath
export PATH="$HOME/.local/bin:$PATH"

echo "🎉 Installed pipx"

echo "⚙ Configuring pip"

mkdir -p "$PIP_DIR"

echo "✅ pip configured"

echo "🔧 Installing pydot and cfn-lint"
python -m pip install --upgrade pip setuptools wheel
python -m pip install pydot
pipx install cfn-lint

echo "✅ cfn-lint and pydot installed"

asdf reshim python
