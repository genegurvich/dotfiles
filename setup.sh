#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo_info "Adding Homebrew to PATH for Apple Silicon..."
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    echo_info "Homebrew is already installed"
fi

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo_info "Dotfiles directory: $DOTFILES_DIR"

# List of files to symlink
FILES_TO_LINK=(
    ".gitconfig"
    ".tmux.conf"
    ".tmux.conf.local"
    ".zshrc"
    ".zshrc.local"
)

# Create symlinks
echo_info "Creating symlinks..."
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

# Run brew install if Brewfile exists
if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    echo_info "Installing packages from Brewfile..."
    cd "$DOTFILES_DIR"
    brew bundle install
else
    echo_warn "No Brewfile found, skipping brew install"
fi

echo_info "Setup complete! 🎉"
echo_info "You may need to restart your terminal or run 'source ~/.zshrc' to apply changes."