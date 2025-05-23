#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

# Set default phase to 'install' if not provided
phase="${1:-install}"
[[ $# -gt 0 ]] && shift

run_install() {
    echo "🔧 Installing Visual Studio Code"

    WIN_USER=$(powershell.exe -NoProfile -Command '[System.Environment]::UserName' | tr -d '\r')

    VSCODE_BIN_PATH="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/bin"
    VSCODE_BIN_PATH_SYSTEM="/mnt/c/Program Files/Microsoft VS Code/bin"

    VSCODE_PATH="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/Code.exe"
    VSCODE_PATH_SYSTEM="/mnt/c/Program Files/Microsoft VS Code/Code.exe"
    VSCODE_SETTINGS_PATH="/mnt/c/Users/$WIN_USER/AppData/Roaming/Code/User/settings.json"

    # ========================================================================
    # Install VS Code
    # ========================================================================

    if [ -f "$VSCODE_PATH" ] || [ -f "$VSCODE_PATH_SYSTEM" ]; then
        echo "⚠️ Visual Studio Code is already installed. Skipping installation."
    else
        curl -L "https://update.code.visualstudio.com/latest/win32-x64-user/stable" -o /tmp/VSCodeSetup.exe \

        local win_path
        win_path=$(wslpath -w /tmp/VSCodeSetup.exe)

        powershell.exe -NoProfile -Command "Start-Process -FilePath '$win_path' -ArgumentList '/silent', '/mergetasks=!runcode' -WorkingDirectory 'C:\' -NoNewWindow -Wait"
        rm -f /tmp/VSCodeSetup.exe
    fi

    # ========================================================================
    # Add self signed cert to vscode's integrated terminal
    # ========================================================================

    # Prepare escaped JSON insertion
    escaped_cert_path="${WIN_CERT_PATH//\\/\\\\}"  # double escape backslashes

    # Create settings.json if it doesn't exist
    mkdir -p "$(dirname "$VSCODE_SETTINGS_PATH")"  
    if [[ ! -f "$VSCODE_SETTINGS_PATH" ]]; then
      echo "{}" > "$VSCODE_SETTINGS_PATH"
    fi

    # Modify settings.json
    tmp_file=$(mktemp)

    jq --arg win_cert "$escaped_cert_path" --arg wsl_cert "$WSL_CERT_PATH" '
      # Ensure terminal.integrated.env.windows exists and NODE_EXTRA_CA_CERTS is set correctly
      (.["terminal.integrated.env.windows"] //= {}) 
      | (.["terminal.integrated.env.linux"] //= {})
      
      | if .["terminal.integrated.env.windows"]["NODE_EXTRA_CA_CERTS"] != $win_cert 
        then .["terminal.integrated.env.windows"]["NODE_EXTRA_CA_CERTS"] = $win_cert 
        else . 
        end
        
      # Ensure terminal.integrated.env.linux exists and NODE_EXTRA_CA_CERTS is set correctly
      | if .["terminal.integrated.env.linux"]["NODE_EXTRA_CA_CERTS"] != $wsl_cert 
        then .["terminal.integrated.env.linux"]["NODE_EXTRA_CA_CERTS"] = $wsl_cert 
        else . 
        end

      # Ensure http.proxyStrictSSL is false if not already
      | if has("http.proxyStrictSSL") then . else .["http.proxyStrictSSL"] = false end

      # Ensure http.systemCertificates is true if not already
      | if has("http.systemCertificates") then . else .["http.systemCertificates"] = true end
    ' "$VSCODE_SETTINGS_PATH" > "$tmp_file" && mv "$tmp_file" "$VSCODE_SETTINGS_PATH"

    echo "✅ VS Code settings updated"

    # ========================================================================
    # Add to path
    # ========================================================================

    if [ -d "$VSCODE_BIN_PATH" ]; then
       if [[ ":$PATH:" != *":$VSCODE_BIN_PATH:"* ]]; then
           export PATH="$PATH:$VSCODE_BIN_PATH"
       fi

    elif [ -d "$VSCODE_BIN_PATH_SYSTEM" ]; then
        if [[ ":$PATH:" != *":$VSCODE_BIN_PATH_SYSTEM:"* ]]; then
           export PATH="$PATH:$VSCODE_BIN_PATH_SYSTEM"
        fi

    else
      echo "Visual Studio Code not found."
    fi
     
    echo "🎉 Installed Visual Studio Code with version: $(code --version)"
}

run_extension_install() {
    pkill -f "Code.exe" 2>/dev/null || true  # Make sure it's not running

    WIN_USER=$(powershell.exe -NoProfile -Command '[System.Environment]::UserName' | tr -d '\r')
    WIN_CERT_PATH=$(powershell.exe -NoProfile -Command '[Environment]::GetEnvironmentVariable("NODE_EXTRA_CA_CERTS", "User")' | tr -d '\r')

    export NODE_EXTRA_CA_CERTS=$(wslpath "$WIN_CERT_PATH") 

    VSCODE_BIN_PATH="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/bin"
    VSCODE_BIN_PATH_SYSTEM="/mnt/c/Program Files/Microsoft VS Code/bin"

    VSCODE_SETTINGS_PATH="/mnt/c/Users/$WIN_USER/AppData/Roaming/Code/User/settings.json"

    if [ -d "$VSCODE_BIN_PATH" ]; then
        export PATH="$PATH:$VSCODE_BIN_PATH"
    elif [ -d "$VSCODE_BIN_PATH_SYSTEM" ]; then
        export PATH="$PATH:$VSCODE_BIN_PATH_SYSTEM"
    fi

    export NODE_OPTIONS="--force-node-api-uncaught-exceptions-policy=true"

    if command -v code >/dev/null 2>&1; then
        echo "📦 Installing Visual Studio Code extensions"

        for ext in "${VS_CODE_EXTENSION[@]}"; do
            echo "🔧 Installing $ext"
            code --install-extension "$ext" --force
        done

        echo "🎉 Installed extensions: $(code --list-extensions)"

        # Make sure settings.json exists
        mkdir -p "$(dirname "$VSCODE_SETTINGS_PATH")"
        [[ -f "$VSCODE_SETTINGS_PATH" ]] || echo "{}" > "$VSCODE_SETTINGS_PATH"

        # Append Copilot settings using jq
        tmp_file=$(mktemp)
        jq '
          # --- GitHub Copilot ---
          (.["github.copilot.enable"] //= {}) as $copilot |
          .["github.copilot.enable"] = ($copilot + {
            "javascript": ($copilot.javascript // true),
            "typescript": ($copilot.typescript // true),
            "javascriptreact": ($copilot.javascriptreact // true),
            "typescriptreact": ($copilot.typescriptreact // true),
            "shellscript": ($copilot.shellscript // true),
            "json": ($copilot.json // true),
            "markdown": ($copilot.markdown // true),
            "yaml": ($copilot.yaml // true),
            "html": ($copilot.html // true),
            "css": ($copilot.css // true),
            "python": ($copilot.python // true)
          }) |
          .["github.copilot.nextEditSuggestions.enabled"] = true |

          # --- ESLint ---
          .["eslint.enable"] = true |
          .["eslint.validate"] = 
            (if (.["eslint.validate"] | type) == "array" 
             then (.["eslint.validate"] + ["javascript", "javascriptreact", "typescript", "typescriptreact"]) 
             else ["javascript", "javascriptreact", "typescript", "typescriptreact"] 
             end | unique) |

          # --- Prettier ---
          .["editor.formatOnSave"] = true |
          .["prettier.requireConfig"] = true |
          .["prettier.singleQuote"] = true |

          # --- Editor ---
          .["editor.formatOnPaste"] = true |
          .["editor.formatOnSave"] = true |
          .["workbench.iconTheme"] = "vscode-icons" |
          .["files.autoSave"] = "onFocusChange" |
          .["[javascriptreact]"] = {
            "editor.defaultFormatter": "esbenp.prettier-vscode"
          } |
          .["[typescriptreact]"] = {
            "editor.defaultFormatter": "esbenp.prettier-vscode"
          } |
          .["[javascript]"] = {
            "editor.defaultFormatter": "esbenp.prettier-vscode"
          } |
          .["[typescript]"] = {
            "editor.defaultFormatter": "esbenp.prettier-vscode"
          } |
          .["[json]"] = {
            "editor.defaultFormatter": "esbenp.prettier-vscode"
          } |
          .["[html]"] = {
            "editor.defaultFormatter": "esbenp.prettier-vscode"
          } |
          .["[css]"] = {
            "editor.defaultFormatter": "esbenp.prettier-vscode"
          } |
          .["[markdown]"] = {
            "editor.defaultFormatter": "esbenp.prettier-vscode"
          }
        ' "$VSCODE_SETTINGS_PATH" > "$tmp_file" && mv "$tmp_file" "$VSCODE_SETTINGS_PATH"

        echo "✅ GitHub Copilot pre-installed and settings configured"
        echo "✅ ESLint pre-installed and settings configured"
        echo "✅ Prettier pre-installed and settings configured"
    else
        echo "🤯 VS Code not found on PATH. Skipping extension installation."
    fi
}

case "$phase" in
  install)
    run_install
    ;;
  packages)
    run_extension_install
    ;;
  *)
    echo "Defaulting to run_install"
    run_install
    ;;
esac

