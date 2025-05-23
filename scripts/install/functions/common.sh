#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "🔧 Installing common toolkit"

asdf plugin add jq https://github.com/AZMCode/asdf-jq.git
asdf install jq latest
asdf set -u jq latest
echo "🎉 Installed jq with version: $(jq --version)"

if [[ "$INSTALL_MODE" == "full" ]]; then
    asdf plugin add peco https://github.com/asdf-community/asdf-peco.git
    asdf install peco latest
    asdf set -u peco latest
    echo "🎉 Installed peco with version: $(peco --version)"

    asdf plugin add ghq
    asdf install ghq latest
    asdf set -u ghq latest
    echo "🎉 Installed ghq with version: $(ghq --version)"
fi


echo "🎉 Installed common toolkit"
