#!/bin/bash

#############################################
# macOS Development Environment Setup Script
# One-command setup for new Mac
# Installs: Homebrew, Claude Code, Node.js, Python, Git, VS Code
#############################################

# Don't exit on error - we want to continue even if some steps fail
set +e

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
    elif [[ "$SHELL" == *"bash"* ]]; then
        echo "bash"
        SHELL_RC="$HOME/.bash_profile"
    else
        # Fallback to zsh as it's default on modern macOS
        echo "zsh"
        SHELL_RC="$HOME/.zshrc"
    fi
    
    # Ensure the shell config file exists
    touch "$SHELL_RC"
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
    # Check if VS Code is already installed
    if [[ -e "/Applications/Visual Studio Code.app" ]]; then
        print_info "VS Code already installed at /Applications/Visual Studio Code.app"
    elif command_exists code; then
        print_info "VS Code already installed (code command available)"
    else
        print_info "Installing VS Code..."
        # Force reinstall if cask thinks it's installed but app is missing
        brew reinstall --cask visual-studio-code || brew install --cask visual-studio-code
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
        echo ""
        echo -n "Do you want to change these settings? (y/N): "
        read -r change_config
        if [[ "$change_config" != "y" && "$change_config" != "Y" ]]; then
            return
        fi
    fi
    
    # Try to get user info from macOS
    local suggested_name=""
    local suggested_email=""
    
    # Try to get full name from macOS
    if command_exists id; then
        suggested_name=$(id -F 2>/dev/null)
    fi
    
    # Try to get name from macOS system
    if [[ -z "$suggested_name" ]]; then
        suggested_name=$(dscl . -read /Users/$(whoami) RealName 2>/dev/null | tail -1 | sed 's/^ *//')
    fi
    
    # Try to get computer name as fallback
    if [[ -z "$suggested_name" ]]; then
        suggested_name=$(scutil --get ComputerName 2>/dev/null)
    fi
    
    # Try to get email from Apple ID (requires user to be logged in)
    # This is stored in various places but not always accessible
    if command_exists defaults; then
        # Try iCloud account
        suggested_email=$(defaults read MobileMeAccounts Accounts 2>/dev/null | grep -m1 "@" | sed 's/.*"\(.*@.*\)".*/\1/' | head -1)
    fi
    
    # Clean up suggested values
    suggested_name=$(echo "$suggested_name" | xargs)
    suggested_email=$(echo "$suggested_email" | xargs)
    
    # Interactive prompt with suggestions
    print_warning "Git configuration needed"
    echo ""
    
    # Name prompt
    if [[ -n "$suggested_name" ]]; then
        echo -n "Enter your name (or press Enter for '$suggested_name'): "
        read -r git_name
        git_name=${git_name:-$suggested_name}
    else
        echo -n "Enter your name: "
        read -r git_name
        while [[ -z "$git_name" ]]; do
            print_error "Name cannot be empty"
            echo -n "Enter your name: "
            read -r git_name
        done
    fi
    
    # Email prompt
    if [[ -n "$suggested_email" ]]; then
        echo -n "Enter your email (or press Enter for '$suggested_email'): "
        read -r git_email
        git_email=${git_email:-$suggested_email}
    else
        echo -n "Enter your email: "
        read -r git_email
        while [[ -z "$git_email" ]]; do
            print_error "Email cannot be empty"
            echo -n "Enter your email: "
            read -r git_email
        done
    fi
    
    # Set git config
    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    
    print_success "Git configured"
    echo "  Name: $git_name"
    echo "  Email: $git_email"
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
    install_vscode || track_error "VS Code installation failed"
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
    echo ""
    if [[ $ERRORS_OCCURRED -eq 0 ]]; then
        print_success "Installation complete! 🎉"
    else
        print_warning "Installation completed with $ERRORS_OCCURRED error(s)"
        print_info "Some components may need manual installation"
    fi
    
    echo ""
    print_warning "IMPORTANT: Run the following commands to apply changes:"
    echo ""
    echo "  source $SHELL_RC"
    echo "  claude --help"
    echo ""
    print_info "Or simply open a new terminal window"
}

# Track errors but don't exit
ERRORS_OCCURRED=0

# Function to track errors
track_error() {
    ERRORS_OCCURRED=$((ERRORS_OCCURRED + 1))
    print_error "$1"
}

# Run main function
main