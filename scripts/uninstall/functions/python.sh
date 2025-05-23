#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstalling Python"

if command -v asdf >/dev/null 2>&1; then
   if asdf plugin list python | grep -q "^python$"; then
        if command -v python >/dev/null 2>&1; then
            echo "🔧 Uninstalling cfn-lint (pipx)"
            if pipx list | grep -q "^cfn-lint"; then
                pipx uninstall cfn-lint
            fi

            echo "🔧 Uninstalling pydot (pip)"
            if python -m pip show pydot >/dev/null 2>&1; then
                python -m pip uninstall -y pydot
            fi

            echo "🔧 Uninstalling pipx"
            python -m pip uninstall -y pipx
            remove_from_shell_config "$ZSHRC_FILE" "$HOME/.local/bin"
        fi

        echo "🔧 Uninstalling Python"
        asdf list python | sed 's/^[* ]*//' | while read -r version; do
            echo "🔧 Uninstalling Python $version"
            asdf uninstall python "$version"
        done

        asdf plugin remove python
    fi
fi

echo "🔧 Removing Python directories and configuration files"
[[ -d "$HOME/.pyenv" ]] && rm -rf "$HOME/.pyenv"
[[ -d "$HOME/.pip" ]] && rm -rf "$HOME/.pip"
[[ -d "$HOME/.local" ]] && rm -rf "$HOME/.local"
[[ -d "$HOME/.cache/pip" ]] && rm -rf "$HOME/.cache/pip"
[[ -d "$HOME/.cache/pipx" ]] && rm -rf "$HOME/.cache/pipx"
[[ -d "$HOME/.pipx" ]] && rm -rf "$HOME/.pipx"
[[ -d "$HOME/.config/pipx" ]] && rm -rf "$HOME/.config/pipx"
[[ -d "$HOME/.config/pip" ]] && rm -rf "$HOME/.config/pip"
[[ -f "$PIPCONF_FILE" ]] && rm -rf "$PIPCONF_FILE"
[[ -d "$HOME/.asdf/installs/python" ]] && rm -rf "$HOME/.asdf/installs/python"
[[ -d "$HOME/.asdf/plugins/python" ]] && rm -rf "$HOME/.asdf/plugins/python"

sed -i '/^# Created by `pipx` on .*$/{
    N
    /^# Created by `pipx` on .*$/s/.*\nexport PATH="\$PATH:\/home\/user\/\.local\/bin"//
}' "$PROFILE_FILE"

echo "✅ Uninstalled Python"
