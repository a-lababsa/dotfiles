#!/bin/bash
# VS Code WSL integration setup script

set -euo pipefail

echo "➡️  Setting up VS Code integration with WSL..."

# Check if we're in WSL
if ! grep -qi microsoft /proc/version; then
  echo "❌ This script must be run under WSL2"
  exit 1
fi

# Check if code command is available
if command -v code >/dev/null 2>&1; then
  echo "✅ VS Code command is already available"
  code --version
else
  echo "🔄 Installing VS Code integration for WSL..."
  
  # Check if VS Code is installed on Windows
  if ! command -v "/mnt/c/Program Files/Microsoft VS Code/bin/code" >/dev/null 2>&1 && \
     ! command -v "/mnt/c/Program Files/Microsoft VS Code Insiders/bin/code-insiders" >/dev/null 2>&1 && \
     ! command -v "/mnt/c/Users/$(cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r')/AppData/Local/Programs/Microsoft VS Code/bin/code" >/dev/null 2>&1; then
    
    echo "⚠️ VS Code does not appear to be installed on Windows."
    echo "   Please install VS Code from https://code.visualstudio.com/ before continuing."
    exit 1
  fi

  # Find VS Code installation
  VSCODE_PATH=""
  if command -v "/mnt/c/Program Files/Microsoft VS Code/bin/code" >/dev/null 2>&1; then
    VSCODE_PATH="/mnt/c/Program Files/Microsoft VS Code/bin/code"
  elif command -v "/mnt/c/Program Files/Microsoft VS Code Insiders/bin/code-insiders" >/dev/null 2>&1; then
    VSCODE_PATH="/mnt/c/Program Files/Microsoft VS Code Insiders/bin/code-insiders"
  elif command -v "/mnt/c/Users/$(cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r')/AppData/Local/Programs/Microsoft VS Code/bin/code" >/dev/null 2>&1; then
    VSCODE_PATH="/mnt/c/Users/$(cmd.exe /c echo %USERNAME% 2>/dev/null | tr -d '\r')/AppData/Local/Programs/Microsoft VS Code/bin/code"
  fi

  # Create the VS Code server installation directory
  mkdir -p ~/.vscode-server/bin

  # Create a symlink for the code command
  mkdir -p ~/.local/bin
  cat > ~/.local/bin/code << EOL
#!/bin/bash
"$VSCODE_PATH" \$@
EOL
  chmod +x ~/.local/bin/code
  
  echo "✅ VS Code command has been set up"
fi

# Install recommended VS Code extensions for development
echo "📦 Installing recommended VS Code extensions..."
code --install-extension ms-vscode-remote.remote-wsl --force || echo "⚠️ Failed to install remote-wsl extension"
code --install-extension ms-vscode.cpptools --force || echo "⚠️ Failed to install cpptools extension"
code --install-extension ms-python.python --force || echo "⚠️ Failed to install python extension"
code --install-extension dbaeumer.vscode-eslint --force || echo "⚠️ Failed to install eslint extension"
code --install-extension esbenp.prettier-vscode --force || echo "⚠️ Failed to install prettier extension"
code --install-extension github.copilot --force || echo "⚠️ Failed to install GitHub Copilot extension"
code --install-extension streetsidesoftware.code-spell-checker --force || echo "⚠️ Failed to install code-spell-checker extension"
code --install-extension ms-azuretools.vscode-docker --force || echo "⚠️ Failed to install docker extension"

# Create VS Code settings directory if it doesn't exist
mkdir -p ~/.vscode

# Create settings.json with recommended settings
if [ ! -f ~/.vscode/settings.json ]; then
  cat > ~/.vscode/settings.json << 'EOL'
{
  "editor.formatOnSave": true,
  "editor.renderWhitespace": "boundary",
  "editor.rulers": [80, 120],
  "editor.tabSize": 2,
  "editor.wordWrap": "on",
  "files.trimTrailingWhitespace": true,
  "terminal.integrated.defaultProfile.linux": "zsh",
  "workbench.colorTheme": "Default Dark+",
  "workbench.startupEditor": "none",
  "python.formatting.provider": "black",
  "python.linting.enabled": true,
  "python.linting.pylintEnabled": true,
  "javascript.updateImportsOnFileMove.enabled": "always",
  "typescript.updateImportsOnFileMove.enabled": "always",
  "git.autofetch": true,
  "git.confirmSync": false,
  "git.enableSmartCommit": true
}
EOL
  echo "✅ Created default VS Code settings"
else
  echo "ℹ️ VS Code settings already exist, skipping"
fi

# Create VS Code workspace file for dotfiles
if [ -d ~/workspace/dotfiles ]; then
  if [ ! -f ~/workspace/dotfiles/dotfiles.code-workspace ]; then
    cat > ~/workspace/dotfiles/dotfiles.code-workspace << 'EOL'
{
  "folders": [
    {
      "path": "."
    }
  ],
  "settings": {
    "editor.formatOnSave": true,
    "editor.renderWhitespace": "boundary",
    "files.associations": {
      "*.yml": "yaml",
      "Taskfile.yml": "yaml",
      "*/tasks/*.yml": "yaml"
    },
    "yaml.schemas": {
      "https://taskfile.dev/schema.json": ["./Taskfile.yml", "./tasks/*.yml"]
    }
  },
  "extensions": {
    "recommendations": [
      "ms-vscode-remote.remote-wsl",
      "redhat.vscode-yaml",
      "timonwong.shellcheck"
    ]
  }
}
EOL
    echo "✅ Created VS Code workspace for dotfiles"
  fi
fi

echo ""
echo "🎉 VS Code WSL integration setup complete!"
echo "To open VS Code from WSL, simply type 'code .' in any directory."
echo "You can also open your dotfiles repo with: code ~/workspace/dotfiles"