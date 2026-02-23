#!/bin/bash

# Source colors
source "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

# Print functions for consistent output
print_status() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# Improved run_cmd function with better error handling
run_cmd() {
    if [[ "$DRY_RUN" == true ]]; then
        echo "  [DRY-RUN] $*"
    else
        if ! eval "$@"; then
            print_error "Command failed: $*"
            return 1
        fi
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Validate file exists and is readable
validate_file() {
    local file="$1"

    if [[ ! -e "$file" ]]; then
        print_error "File not found: $file"
        return 1
    fi

    if [[ ! -r "$file" ]]; then
        print_error "File not readable: $file"
        return 1
    fi

    return 0
}

# Install a binary from GitHub releases (Linux only)
# Usage: install_github_binary <name> <owner/repo> <asset_pattern> [binary_name]
install_github_binary() {
    local name="$1"
    local repo="$2"
    local asset_pattern="$3"
    local binary_name="${4:-$name}"

    if command -v "$binary_name" >/dev/null 2>&1; then
        print_status "$name is already installed"
        return 0
    fi

    print_status "Installing $name from GitHub releases..."

    local tmpdir
    tmpdir=$(mktemp -d)
    local arch
    arch=$(dpkg --print-architecture 2>/dev/null || uname -m)

    # Map architecture names
    local arch_pattern
    case "$arch" in
        amd64|x86_64) arch_pattern="x86_64|amd64" ;;
        arm64|aarch64) arch_pattern="aarch64|arm64" ;;
        *) print_warning "Unsupported architecture: $arch"; rm -rf "$tmpdir"; return 1 ;;
    esac

    # Get latest release asset URL
    local download_url
    download_url=$(curl -sL "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oP '"browser_download_url":\s*"\K[^"]+' \
        | grep -iE "$asset_pattern" \
        | grep -iE "$arch_pattern" \
        | grep -iv "musl\|\.sha256\|\.sig\|\.asc" \
        | head -1)

    if [[ -z "$download_url" ]]; then
        print_warning "Could not find $name release for $arch"
        rm -rf "$tmpdir"
        return 1
    fi

    local filename
    filename=$(basename "$download_url")

    curl -sL "$download_url" -o "$tmpdir/$filename"

    # Extract and install based on file type
    case "$filename" in
        *.tar.gz|*.tgz)
            tar -xzf "$tmpdir/$filename" -C "$tmpdir"
            local bin_path
            bin_path=$(find "$tmpdir" -name "$binary_name" -type f -executable 2>/dev/null | head -1)
            if [[ -z "$bin_path" ]]; then
                bin_path=$(find "$tmpdir" -name "$binary_name" -type f 2>/dev/null | head -1)
            fi
            if [[ -n "$bin_path" ]]; then
                install -m 755 "$bin_path" "$HOME/.local/bin/$binary_name"
            else
                print_warning "Binary $binary_name not found in archive"
                rm -rf "$tmpdir"
                return 1
            fi
            ;;
        *.deb)
            sudo dpkg -i "$tmpdir/$filename"
            ;;
        *.zip)
            unzip -o "$tmpdir/$filename" -d "$tmpdir"
            local bin_path
            bin_path=$(find "$tmpdir" -name "$binary_name" -type f -executable 2>/dev/null | head -1)
            if [[ -n "$bin_path" ]]; then
                install -m 755 "$bin_path" "$HOME/.local/bin/$binary_name"
            fi
            ;;
        *)
            install -m 755 "$tmpdir/$filename" "$HOME/.local/bin/$binary_name"
            ;;
    esac

    rm -rf "$tmpdir"

    if command -v "$binary_name" >/dev/null 2>&1; then
        print_status "$name installed successfully"
    else
        print_warning "$name installation may have failed"
    fi
}