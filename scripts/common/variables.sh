#!/usr/bin/env bash

export GITHUB_HOST="github.com"

export TMP_DIR="${TMPDIR:-/tmp}"

export OHMYZSH_INTALL_PATH=https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
export LINUXBREW_INSTALL_PATH=https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

export CURLRC_FILE="$HOME/.curlrc"
export WGETRC_FILE="$HOME/.wgetrc"
export ZSHRC_FILE="$HOME/.zshrc"
export BASHRC_FILE="$HOME/.bashrc"
export PROFILE_FILE="$HOME/.profile"
export NVM_DIR="$HOME/.nvm"
export ASDF_DIR="$HOME/.asdf"
export NPMRC_FILE="$HOME/.npmrc"
export YARNRC_FILE="$HOME/.yarnrc"
export PIP_DIR="$HOME/.pip"
export PIPCONF_FILE="$PIP_DIR/pip.conf"
export MAVEN_DIR="$HOME/.m2"
export MAVEN_CONFIG_FILE="$MAVEN_DIR/settings.xml"

export BREW_PACKAGES=(
  "gcc"
  "pixman"
  "cairo"
  "pango"
  "readline"
  "openssl"
  "libjpeg-turbo"
  "giflib"
  "pkg-config"
  "sqlite3"
  "zlib"
  "tcl-tk"
  "mpdecimal"
  "hello"
  "zip"
  "unzip"
  "gnu-tar"
  "xz"
  "gzip"
  "bzip2"
  "figlet"
  "lolcat"
  "gnupg"
)

export ZSH_PLUGINS=(
  "zsh-autosuggestions"
  "zsh-autocomplete"
  "zsh-syntax-highlighting"
  "git"
  "brew"
  "asdf"
  "nvm"
  "npm"
  "aws"
)

export NODE_VERSIONS=(
  "18.16.0"
  "18.18.0"
  "20.11.0"
  "22.5.1"
)

export VS_CODE_EXTENSION=(
    "vscode-icons-team.vscode-icons"
    "ms-vscode-remote.remote-wsl"
    "christian-kohler.npm-intellisense"
    "christian-kohler.path-intellisense"
    "mikestead.dotenv"
    "kddejong.vscode-cfn-lint"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "orta.vscode-jest"
    "timonwong.shellcheck"
    "shd101wyy.markdown-preview-enhanced"
    "github.copilot"
    "github.copilot-chat"
    "amazonwebservices.aws-toolkit-vscode"
    "rangav.vscode-thunder-client"
)

if [[ "$INSTALL_MODE" == "full" ]]; then
    VS_CODE_EXTENSION+=("ms-azuretools.vscode-docker")
    VS_CODE_EXTENSION+=("vscjava.vscode-java-pack")
fi

# shellcheck disable=SC2016
export GPG_SSH_BLOCK='
# Start SSH agent if not running
if ! pgrep -u "$USER" ssh-agent >/dev/null 2>&1; then
    eval "$(ssh-agent -s)"
fi

# Set GPG TTY for commut signing
export GPG_TTY=$(tty)

# Start GPG agent 
gpgconf --launch gpg-agent
'

export ASDF_CONFIG_BLOCK=$(cat <<EOF
# ASDF setup
export ASDF_DATA_DIR="$ASDF_DIR"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:\$PATH"
EOF
)

export CARGO_TOML_BLOCK=$(cat <<EOF
EOF
)

export ZSH_COMPINIT_BLOCK=$(cat <<EOF
# Init completion
autoload -Uz compinit
compinit
EOF
)

# shellcheck disable=SC2016
export ZSH_PLUGIN_INIT_BLOCK='
# --- Source plugins from $ZSH_CUSTOM (safe) ---
[[ -f "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$ZSH_CUSTOM/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh" ]] && source "$ZSH_CUSTOM/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
[[ -f "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
'

# shellcheck disable=SC2016
export COMPILER_AND_LINKER_FLAGS_BLOCK='
# Compiler and linker flags for openssl installed by brew
export LDFLAGS="-Wl,-rpath,$(brew --prefix openssl@3)/lib"
export CONFIGURE_OPTS="--with-openssl=$(brew --prefix openssl@3) --with-openssl-rpath=auto"
'

# shellcheck disable=SC2016
export LD_LIBRARY_PATH_BLOCK='
# LD_LIBRARY_PATH setup
export LD_LIBRARY_PATH=$(brew --prefix mpdecimal)/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$(brew --prefix sqlite)/lib:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=$(brew --prefix zlib)/lib:$LD_LIBRARY_PATH
# Not a good idea to use Linuxbrew installed OpenSSL 3 which can be 
# problematic in WSL2, when combined with zsh, where config files
# may load this path.
# SSL hangs at handshake, indicating incompatibility between OpenSSL 3 (linuxbrew)
# and the systems curl library, likely compiled against a different version of OpenSSL.
# export LD_LIBRARY_PATH=$(brew --prefix openssl@3)/lib:$LD_LIBRARY_PATH
'

export NPM_CONFIG_BLOCK=$(cat <<EOF
export NPM_CONFIG_USERCONFIG="$NPMRC_FILE"
EOF
)

# shellcheck disable=SC2016
export NVM_HOOK_BLOCK='
autoload -U add-zsh-hook

load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc
'

# shellcheck disable=SC2016
export JAVA_CONFIG_BLOCK='
JAVA_HOME_PATH="$(asdf where java)"
export JAVA_HOME="$JAVA_HOME_PATH"
export PATH="$JAVA_HOME/bin:$PATH"
'

# shellcheck disable=SC2016
export MAVEN_CONFIG_BLOCK='
MAVEN_HOME_PATH="$(asdf where maven)"
export MAVEN_HOME="$MAVEN_HOME_PATH"
export PATH="$MAVEN_HOME/bin:$PATH"
'

# Flags for Maven that will be written to .mavenrc
export MAVEN_FLAGS="MAVEN_OPTS=\"--enable-native-access=ALL-UNNAMED\""

# Add aliases for bat and eza
export BAT_EZA_FZF_SETUP='
alias cat="bat --theme=OneHalfDark --color=always"
alias ls="exa"

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
'