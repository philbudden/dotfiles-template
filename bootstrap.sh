#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Add package directory names here as you create them under stow/. For example:
# stow_packages=(shell git)
stow_packages=()

load_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        return 0
    fi

    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        return 0
    fi

    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        return 0
    fi

    return 1
}

install_homebrew() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "Homebrew needs curl to install. Install curl, then rerun this script." >&2
        exit 1
    fi

    echo "Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

configure_homebrew_path() {
    brew_path="$(command -v brew)"
    shell_name="$(basename "${SHELL:-bash}")"
    shellenv_line='eval "$('"$brew_path"' shellenv)"'

    case "$shell_name" in
        zsh)
            profile_path="$HOME/.zprofile"
            ;;
        bash)
            profile_path="$HOME/.bashrc"
            ;;
        *)
            echo "Homebrew is available in this shell, but $shell_name is not configured automatically."
            echo "Add this to that shell's startup file: $shellenv_line"
            return 0
            ;;
    esac

    if ! grep -Fqx "$shellenv_line" "$profile_path" 2>/dev/null; then
        printf '\n# Homebrew\n%s\n' "$shellenv_line" >> "$profile_path"
        echo "Configured Homebrew for future $shell_name sessions in $profile_path"
    fi
}

if ! load_homebrew; then
    install_homebrew
    load_homebrew || {
        echo "Homebrew was installed but could not be found. Open a new shell and rerun this script." >&2
        exit 1
    }
fi

configure_homebrew_path

echo "Installing tools from Brewfile..."
brew bundle --file "$repo_dir/Brewfile"

if [ "${#stow_packages[@]}" -gt 0 ]; then
    echo "Linking selected dotfiles with GNU Stow..."
    stow --dir "$repo_dir/stow" --target "$HOME" "${stow_packages[@]}"
fi

echo "Done. Homebrew and the template CLI tools are ready."
