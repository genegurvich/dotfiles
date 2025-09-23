#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

echo_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo_step() {
    echo -e "${BLUE}==>${NC} $1"
}

# Configuration
REPO_URL="https://github.com/genegurvich/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo_step "Installing Gene's dotfiles"
echo

# Check if Xcode Command Line Tools are installed
if ! xcode-select -p &> /dev/null; then
    echo_info "Xcode Command Line Tools not found. Installing..."

    # Try to install Xcode CLT
    if xcode-select --install 2>/dev/null; then
        echo_info "Xcode Command Line Tools installation started..."
    else
        echo_warn "Xcode Command Line Tools installation dialog may already be open"
    fi

    # Wait for installation to complete
    echo_info "Waiting for Xcode Command Line Tools installation to complete..."
    while ! xcode-select -p &> /dev/null; do
        printf "."
        sleep 5
    done
    echo
    echo_info "Xcode Command Line Tools installation complete!"
fi

# Verify git is available
if ! command -v git &> /dev/null; then
    echo_error "Git is still not available after Xcode Command Line Tools installation"
    echo_error "Please install git manually and run this script again"
    exit 1
fi

# Check if SSH key exists, create if not
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
if [[ ! -f "$SSH_KEY_PATH" ]]; then
    echo_step "Setting up SSH key..."

    # Create .ssh directory if it doesn't exist
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    # Generate SSH key
    echo_info "Generating SSH key..."
    ssh-keygen -t ed25519 -f "$SSH_KEY_PATH" -N "" -C "$(whoami)@$(hostname)"

    # Add to ssh-agent
    echo_info "Adding SSH key to ssh-agent..."
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add "$SSH_KEY_PATH" 2>/dev/null

    # Add to SSH config for persistent agent
    SSH_CONFIG="$HOME/.ssh/config"
    if [[ ! -f "$SSH_CONFIG" ]] || ! grep -q "AddKeysToAgent yes" "$SSH_CONFIG"; then
        echo_info "Configuring SSH agent..."
        cat >> "$SSH_CONFIG" << EOF

Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF
        chmod 600 "$SSH_CONFIG"
    fi

    echo_info "SSH key generated: $SSH_KEY_PATH.pub"
    echo_warn "IMPORTANT: Add your SSH public key to GitHub:"
    echo_warn "  1. Copy: pbcopy < $SSH_KEY_PATH.pub"
    echo_warn "  2. Go to: https://github.com/settings/ssh/new"
    echo_warn "  3. Paste and save the key"
    echo_warn ""
    read -r -p "Press Enter after adding the SSH key to GitHub..."
else
    echo_info "SSH key already exists at $SSH_KEY_PATH"
    # Ensure key is added to agent
    ssh-add "$SSH_KEY_PATH" 2>/dev/null || true
fi

# Clone or update the repository
if [[ -d "$DOTFILES_DIR" ]]; then
    echo_info "Dotfiles directory exists. Updating..."
    cd "$DOTFILES_DIR"
    git pull origin main
else
    echo_info "Cloning dotfiles repository..."
    git clone "$REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# Install oh-my-zsh if not present
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo_step "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo_info "oh-my-zsh is already installed"
fi

# Ensure .zshrc sources .zshrc.local
ZSHRC_SOURCE_LINE="[[ -f $HOME/.zshrc.local ]] && source $HOME/.zshrc.local"
if [[ -f "$HOME/.zshrc" ]] && ! grep -q "source.*\.zshrc\.local" "$HOME/.zshrc"; then
    echo_info "Adding .zshrc.local source to .zshrc..."
    echo "" >> "$HOME/.zshrc"
    echo "# Source local configuration" >> "$HOME/.zshrc"
    echo "$ZSHRC_SOURCE_LINE" >> "$HOME/.zshrc"
fi

# List of files to symlink
FILES_TO_LINK=(
    ".gitconfig"
    ".tmux.conf"
    ".tmux.conf.local"
    ".zshrc.local"
)

# iTerm2 preferences
ITERM_SOURCE="$DOTFILES_DIR/com.googlecode.iterm2.plist"
ITERM_TARGET="$HOME/Library/Preferences/com.googlecode.iterm2.plist"

if [[ -f "$ITERM_SOURCE" ]]; then
    echo_step "Setting up iTerm2 preferences..."

    # Backup existing iTerm2 preferences if they exist and are not a symlink
    if [[ -f "$ITERM_TARGET" && ! -L "$ITERM_TARGET" ]]; then
        echo_warn "Backing up existing iTerm2 preferences to com.googlecode.iterm2.plist.backup"
        mv "$ITERM_TARGET" "${ITERM_TARGET}.backup"
    elif [[ -L "$ITERM_TARGET" ]]; then
        echo_info "Removing existing iTerm2 preferences symlink"
        rm "$ITERM_TARGET"
    fi

    echo_info "Symlinking iTerm2 preferences"
    ln -s "$ITERM_SOURCE" "$ITERM_TARGET"

    # Reload iTerm2 preferences if iTerm2 is running
    if pgrep -x "iTerm2" > /dev/null; then
        echo_info "Reloading iTerm2 preferences..."
        defaults read com.googlecode.iterm2 > /dev/null 2>&1
    fi
else
    echo_warn "iTerm2 preferences file not found in dotfiles, skipping"
fi

# Create symlinks
echo_step "Creating symlinks..."
for file in "${FILES_TO_LINK[@]}"; do
    source_file="$DOTFILES_DIR/$file"
    target_file="$HOME/$file"

    if [[ -f "$source_file" ]]; then
        # Backup existing file if it exists and is not a symlink
        if [[ -f "$target_file" && ! -L "$target_file" ]]; then
            echo_warn "Backing up existing $file to ${file}.backup"
            mv "$target_file" "${target_file}.backup"
        elif [[ -L "$target_file" ]]; then
            echo_info "Removing existing symlink for $file"
            rm "$target_file"
        fi

        echo_info "Symlinking $file"
        ln -s "$source_file" "$target_file"
    else
        echo_warn "Source file $source_file not found, skipping"
    fi
done

# Symlink the .tmux directory
if [[ -d "$DOTFILES_DIR/.tmux" ]]; then
    if [[ -d "$HOME/.tmux" && ! -L "$HOME/.tmux" ]]; then
        echo_warn "Backing up existing .tmux directory to .tmux.backup"
        mv "$HOME/.tmux" "$HOME/.tmux.backup"
    elif [[ -L "$HOME/.tmux" ]]; then
        echo_info "Removing existing .tmux symlink"
        rm "$HOME/.tmux"
    fi

    echo_info "Symlinking .tmux directory"
    ln -s "$DOTFILES_DIR/.tmux" "$HOME/.tmux"
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo_info "Adding Homebrew to PATH for Apple Silicon..."
        BREW_SHELLENV='eval "$(/opt/homebrew/bin/brew shellenv)"'
        if ! grep -q "$BREW_SHELLENV" ~/.zprofile 2>/dev/null; then
            echo "$BREW_SHELLENV" >> ~/.zprofile
        fi
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo_info "Homebrew is already installed"
fi

# Run brew install if Brewfile exists
if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    echo_step "Installing packages from Brewfile..."
    cd "$DOTFILES_DIR"
    brew bundle install
else
    echo_warn "No Brewfile found, skipping brew install"
fi

echo
echo_step "Installation complete! 🎉"
echo_info "Repository cloned to: $DOTFILES_DIR"
echo_info "To update in the future, run: curl -fsSL https://raw.githubusercontent.com/genegurvich/dotfiles/main/install.sh | bash"
echo_info "You may need to restart your terminal or run 'source ~/.zshrc' to apply changes."