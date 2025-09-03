# macOS Development Environment Auto-Setup 🚀

One-command setup for a fresh macOS installation. Automatically installs and configures all essential development tools including Claude Code.

## 🎯 What Gets Installed

- **Homebrew** - Package manager for macOS
- **Xcode Command Line Tools** - Essential development tools
- **Claude Code** - AI-powered coding assistant CLI
- **Git** - Version control system
- **Node.js & npm** - JavaScript runtime and package manager
- **Python 3.12** - Python programming language
- **VS Code** - Visual Studio Code editor
- **wget & curl** - Command line download tools

## 🏃‍♂️ Quick Start

Run this single command in Terminal on a fresh Mac:

```bash
curl -fsSL https://raw.githubusercontent.com/petrochen/ccode-setup/main/install.sh | bash
```

## 📋 Requirements

- macOS (Intel or Apple Silicon)
- Administrator password (will be requested once during installation)
- Internet connection

## 🔧 What the Script Does

1. **Detects your system** - Identifies if you're on Intel or Apple Silicon Mac
2. **Installs Xcode Tools** - Required for development (will open a dialog)
3. **Installs Homebrew** - The missing package manager for macOS
4. **Installs development tools** - Git, Node.js, Python, etc.
5. **Installs VS Code** - Popular code editor
6. **Installs Claude Code** - AI coding assistant
7. **Fixes PATH** - Ensures Claude Code is accessible from terminal
8. **Configures Git** - Sets up your name and email (optional)
9. **Verifies everything** - Checks all tools are properly installed

## 🤖 Manual Interactions Required

The script is mostly automatic, but will ask for:

1. **Administrator password** - Once for Homebrew installation
2. **Xcode license agreement** - Click "Agree" in the popup
3. **Git configuration** (optional) - Your name and email for commits

## 🛠️ Post-Installation

After the script completes, run:

```bash
source ~/.zshrc  # or ~/.bash_profile for bash
claude --help    # Verify Claude Code works
```

Or simply **open a new Terminal window** to refresh your environment.

## 📁 Alternative: Download and Run Locally

If you prefer to review the script first:

```bash
# Download the script
curl -fsSL https://raw.githubusercontent.com/petrochen/ccode-setup/main/install.sh -o install.sh

# Review it
cat install.sh

# Make it executable and run
chmod +x install.sh
./install.sh
```

## 🔍 Troubleshooting

### Claude Code not found after installation

The script automatically adds `~/.local/bin` to your PATH. If `claude` command still doesn't work:

```bash
# For zsh (default on modern macOS)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# For bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bash_profile
source ~/.bash_profile
```

### Homebrew installation fails

If Homebrew installation fails, try manually:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Permission denied errors

Make sure you have administrator access on your Mac. The script will request your password when needed.

## 🎨 Customization

You can fork this repository and modify `install.sh` to:

- Add more tools (Docker, Rust, Go, etc.)
- Change Python version
- Add your preferred VS Code extensions
- Configure additional Git settings
- Install other applications via Homebrew Cask

## 📝 Manual Steps (if automatic script fails)

1. **Install Homebrew:**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Add Homebrew to PATH (Apple Silicon):**
   ```bash
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
   eval "$(/opt/homebrew/bin/brew shellenv)"
   ```

3. **Install tools:**
   ```bash
   brew install wget curl git node python@3.12
   brew install --cask visual-studio-code
   ```

4. **Install Claude Code:**
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   ```

5. **Fix Claude Code PATH:**
   ```bash
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

## 🤝 Contributing

Feel free to submit issues or pull requests if you have suggestions for improvements!

## 📄 License

MIT License - Feel free to use and modify as needed.

## 🙏 Acknowledgments

- [Homebrew](https://brew.sh/) team for the amazing package manager
- [Anthropic](https://anthropic.com/) for Claude Code
- All the open source tool maintainers

---

**Note:** This script is designed for fresh macOS installations. Running on a system with existing development tools will skip already installed components.