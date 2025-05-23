#!/usr/bin/env zsh

set -euo pipefail

source ./scripts/install/functions/asdf.sh

if [[ "$INSTALL_MODE" == "full" ]]; then
    source ./scripts/install/functions/rust.sh
    source ./scripts/install/functions/ruby.sh
fi

source ./scripts/install/functions/common.sh
source ./scripts/install/functions/python.sh

if [[ "$INSTALL_MODE" == "full" ]]; then
    source ./scripts/install/functions/java.sh
    source ./scripts/install/functions/maven.sh
fi

source ./scripts/install/functions/awscli.sh
source ./scripts/install/functions/node.sh

if [[ "$INSTALL_MODE" == "full" ]]; then
    source ./scripts/install/functions/docker.sh
fi

source ./scripts/install/functions/pnpm.sh
source ./scripts/install/functions/yarn.sh
source ./scripts/install/functions/chrome.sh
source ./scripts/install/functions/vscode.sh
