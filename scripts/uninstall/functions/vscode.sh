#!/usr/bin/env zsh

source ./scripts/common/variables.sh
source ./scripts/common/utils.sh

echo "⚙ Uninstalling Visual Studio Code"

WIN_USER=$(powershell.exe -NoProfile -Command '[System.Environment]::UserName' | tr -d '\r')
VSCODE_PATH="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/Code.exe"
VSCODE_PATH_SYSTEM="/mnt/c/Program Files/Microsoft VS Code/Code.exe"
VSCODE_BIN_PATH="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/bin"
VSCODE_BIN_PATH_SYSTEM="/mnt/c/Program Files/Microsoft VS Code/bin"

# Unset NODE_EXTRA_CA_CERTS from Windows environment
echo "🔧 Removing NODE_EXTRA_CA_CERTS environment variable..."
powershell.exe -NoProfile -Command "[Environment]::SetEnvironmentVariable('NODE_EXTRA_CA_CERTS', \$null, 'User')"
echo "✅ NODE_EXTRA_CA_CERTS unset."

# Delete the certificate file
if [ -f "$WSL_CERT_PATH" ]; then
    echo "🗑️ Removing certificate file..."
    rm -f "$WSL_CERT_PATH"
    echo "✅ Removed $WSL_CERT_PATH"
fi

# Uninstaller paths
VSCODE_USER_UNINSTALLER="/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code/unins000.exe"
VSCODE_USER_UNINSTALLER_WIN=$(wslpath -w "$VSCODE_USER_UNINSTALLER")
VSCODE_SYSTEM_UNINSTALLER="/mnt/c/Program Files/Microsoft VS Code/unins000.exe"
VSCODE_SYSTEM_UNINSTALLER_WIN=$(wslpath -w "$VSCODE_SYSTEM_UNINSTALLER")

# Check if VS Code is installed and uninstall
if [ -f "$VSCODE_USER_UNINSTALLER" ]; then
    echo "📦 Uninstalling Visual Studio Code (user install)..."
    powershell.exe -NoProfile -Command "Start-Process -FilePath '$VSCODE_USER_UNINSTALLER_WIN' -ArgumentList '/silent' -WorkingDirectory 'C:\' -NoNewWindow -Wait"
elif [ -f "$VSCODE_SYSTEM_UNINSTALLER" ]; then
    echo "📦 Uninstalling Visual Studio Code (system install)..."
    powershell.exe -NoProfile -Command "Start-Process -FilePath '$VSCODE_SYSTEM_UNINSTALLER_WIN' -ArgumentList '/silent' -WorkingDirectory 'C:\' -NoNewWindow -Wait"
else
    echo "ℹ️ VS Code not found — skipping uninstall."
fi

# Optionally remove VS Code from PATH (note: this won't persist in current shell session)
if [[ "$PATH" == *"$VSCODE_BIN_PATH"* ]]; then
    echo "🧹 Removing VS Code bin path from PATH..."
    export PATH="${PATH//$VSCODE_BIN_PATH:/}"
fi

if [[ "$PATH" == *"$VSCODE_BIN_PATH_SYSTEM"* ]]; then
    echo "🧹 Removing system VS Code bin path from PATH..."
    export PATH="${PATH//$VSCODE_BIN_PATH_SYSTEM:/}"
fi

echo "✅ Uninstall process complete."

# VSCode User settings, extensions, cache etc.
VSCODE_DIRS_TO_DELETE=(
  "$HOME/.vscode-server"
  "$HOME/.vscode-server-insiders"
  "$HOME/.dotnet"
  "/mnt/c/Users/$WIN_USER/AppData/Roaming/Code"
  "/mnt/c/Users/$WIN_USER/.vscode"
  "/mnt/c/Users/$WIN_USER/.vscode-insiders/extensions"
  "/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code"
  "/mnt/c/Users/$WIN_USER/AppData/Local/Code"
  "/mnt/c/Users/$WIN_USER/AppData/Roaming/Code - Insiders"
  "/mnt/c/Users/$WIN_USER/AppData/Local/Programs/Microsoft VS Code Insiders"
  "/mnt/c/Users/$WIN_USER/AppData/Roaming/Code"
)

# Remove leftover config directories
echo "🧹 Cleaning up leftover VSCode directories..."
for dir in "${VSCODE_DIRS_TO_DELETE[@]}"; do
  if [ -d "$dir" ]; then
    echo "🧹 Removing $dir..."
    rm -rf "$dir" || echo "⚠️ Could not delete $dir (maybe permission issue)"
  else
    echo "✅ $dir already removed or not found."
  fi
done

echo "🏁 Finished cleaning Visual Studio Code directories."

echo "✅ Visual Studio Code uninstalled"
