#!/bin/bash

#############################################
# macOS Development Environment Setup Script
# One-command setup for new Mac
# Installs: Homebrew, Claude Code, Node.js, Python, Git, VS Code
#############################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# ASCII Art Banner
print_banner() {
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════╗
║   macOS Dev Environment Auto-Setup        ║
║   Claude Code + All Essential Tools       ║
╚═══════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Detect system architecture
detect_architecture() {
    if [[ $(uname -m) == 'arm64' ]]; then
        echo "apple_silicon"
        BREW_PREFIX="/opt/homebrew"
    else
        echo "intel"
        BREW_PREFIX="/usr/local"
    fi
}

# Detect shell
detect_shell() {
    if [[ "$SHELL" == *"zsh"* ]]; then
        echo "zsh"
        SHELL_RC="$HOME/.zshrc"
    else
        echo "bash"
        SHELL_RC="$HOME/.bash_profile"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Add to PATH in shell config
add_to_path() {
    local path_to_add="$1"
    local shell_rc="$2"
    
    if ! grep -q "$path_to_add" "$shell_rc" 2>/dev/null; then
        echo "export PATH=\"$path_to_add:\$PATH\"" >> "$shell_rc"
        print_success "Added $path_to_add to PATH in $shell_rc"
    else
        print_info "$path_to_add already in PATH"
    fi
}

# Install Homebrew
install_homebrew() {
    if command_exists brew; then
        print_info "Homebrew already installed"
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ "$ARCH" == "apple_silicon" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$SHELL_RC"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$SHELL_RC"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        print_success "Homebrew installed"
    fi
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    if xcode-select -p &>/dev/null; then
        print_info "Xcode Command Line Tools already installed"
    else
        print_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        
        # Wait for installation
        print_warning "Please complete the Xcode Tools installation in the popup window"
        print_warning "Press Enter when installation is complete..."
        read -r
        
        print_success "Xcode Command Line Tools installed"
    fi
}

# Install development tools via Homebrew
install_dev_tools() {
    print_info "Installing development tools..."
    
    local tools=(
        "wget"
        "curl"
        "git"
        "node"
        "python@3.12"
    )
    
    for tool in "${tools[@]}"; do
        if brew list "$tool" &>/dev/null; then
            print_info "$tool already installed"
        else
            print_info "Installing $tool..."
            brew install "$tool"
            print_success "$tool installed"
        fi
    done
}

# Install VS Code
install_vscode() {
    if command_exists code; then
        print_info "VS Code already installed"
    else
        print_info "Installing VS Code..."
        brew install --cask visual-studio-code
        print_success "VS Code installed"
    fi
}

# Install Claude Code
install_claude_code() {
    print_info "Installing Claude Code..."
    
    # Download and run Claude Code installer
    curl -fsSL https://claude.ai/install.sh | bash
    
    # Add Claude Code to PATH
    add_to_path "$HOME/.local/bin" "$SHELL_RC"
    
    # Source the shell config
    source "$SHELL_RC"
    
    print_success "Claude Code installed"
}

# Configure Git (with optional user input)
configure_git() {
    print_info "Configuring Git..."
    
    # Check if git config already set
    if git config --global user.name &>/dev/null && git config --global user.email &>/dev/null; then
        print_info "Git already configured"
        echo "  Name: $(git config --global user.name)"
        echo "  Email: $(git config --global user.email)"
    else
        # Ask for user input or use defaults
        print_warning "Git configuration needed"
        echo -n "Enter your name (or press Enter for 'Developer'): "
        read -r git_name
        git_name=${git_name:-Developer}
        
        echo -n "Enter your email (or press Enter for 'dev@example.com'): "
        read -r git_email
        git_email=${git_email:-dev@example.com}
        
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        
        print_success "Git configured"
    fi
}

# Verify installations
verify_installations() {
    print_info "Verifying installations..."
    echo ""
    
    local commands=(
        "brew:Homebrew"
        "git:Git"
        "node:Node.js"
        "npm:npm"
        "python3:Python"
        "code:VS Code"
    )
    
    for cmd_pair in "${commands[@]}"; do
        IFS=':' read -r cmd name <<< "$cmd_pair"
        if command_exists "$cmd"; then
            version=$($cmd --version 2>&1 | head -n1)
            echo -e "${GREEN}✅ $name:${NC} $version"
        else
            echo -e "${RED}❌ $name:${NC} Not found"
        fi
    done
    
    # Special check for Claude Code
    if [[ -f "$HOME/.local/bin/claude" ]]; then
        echo -e "${GREEN}✅ Claude Code:${NC} Installed at ~/.local/bin/claude"
    else
        echo -e "${YELLOW}⚠️  Claude Code:${NC} Not found - may need to restart shell"
    fi
}

# Main installation flow
main() {
    clear
    print_banner
    
    # System detection
    print_info "Detecting system configuration..."
    ARCH=$(detect_architecture)
    SHELL_TYPE=$(detect_shell)
    
    echo "  Architecture: $ARCH"
    echo "  Shell: $SHELL_TYPE"
    echo "  Shell RC: $SHELL_RC"
    echo ""
    
    # Installation steps
    print_info "Starting installation process..."
    echo ""
    
    # Step 1: Xcode Tools
    print_info "[1/7] Xcode Command Line Tools"
    install_xcode_tools
    echo ""
    
    # Step 2: Homebrew
    print_info "[2/7] Homebrew"
    install_homebrew
    echo ""
    
    # Step 3: Development tools
    print_info "[3/7] Development tools (git, node, python, etc.)"
    install_dev_tools
    echo ""
    
    # Step 4: VS Code
    print_info "[4/7] Visual Studio Code"
    install_vscode
    echo ""
    
    # Step 5: Claude Code
    print_info "[5/7] Claude Code"
    install_claude_code
    echo ""
    
    # Step 6: Git configuration
    print_info "[6/7] Git configuration"
    configure_git
    echo ""
    
    # Step 7: Verification
    print_info "[7/7] Verification"
    verify_installations
    echo ""
    
    # Fix Claude Code PATH
    print_info "Fixing Claude Code PATH..."
    add_to_path "$HOME/.local/bin" "$SHELL_RC"
    
    # Final message
    print_success "Installation complete! 🎉"
    echo ""
    print_warning "IMPORTANT: Run the following commands to apply changes:"
    echo ""
    echo "  source $SHELL_RC"
    echo "  claude --help"
    echo ""
    print_info "Or simply open a new terminal window"
}

# Error handling
trap 'print_error "An error occurred. Installation may be incomplete."; exit 1' ERR

# Run main function
main