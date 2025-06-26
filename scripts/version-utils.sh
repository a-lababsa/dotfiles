#!/bin/bash
# Version checking and caching utilities

set -euo pipefail

CACHE_DIR="$HOME/.cache/dotfiles"
mkdir -p "$CACHE_DIR"

# Function to check if a tool is already installed with the correct version
check_version() {
    local tool="$1"
    local expected_version="$2"
    local version_command="$3"
    
    if ! command -v "$tool" >/dev/null 2>&1; then
        return 1
    fi
    
    local current_version
    current_version=$(eval "$version_command" 2>/dev/null | head -n1 || echo "unknown")
    
    if [[ "$current_version" == *"$expected_version"* ]]; then
        echo "✅ $tool v$expected_version already installed"
        return 0
    else
        echo "⚠️ $tool version mismatch. Expected: $expected_version, Found: $current_version"
        return 1
    fi
}

# Function to download with caching
download_with_cache() {
    local url="$1"
    local filename="$2"
    local cache_file="$CACHE_DIR/$filename"
    
    if [[ -f "$cache_file" ]]; then
        echo "📦 Using cached $filename"
        echo "$cache_file"
        return 0
    fi
    
    echo "⬇️ Downloading $filename..."
    if curl -fsSL "$url" -o "$cache_file"; then
        echo "✅ Downloaded and cached $filename"
        echo "$cache_file"
        return 0
    else
        echo "❌ Failed to download $filename"
        rm -f "$cache_file"
        return 1
    fi
}

# Function to check system requirements
check_system_requirements() {
    echo "🔍 Checking system requirements..."
    
    # Check if running on WSL2
    if ! grep -qi microsoft /proc/version; then
        echo "❌ This setup is designed for WSL2. Current system not supported."
        return 1
    fi
    
    # Check Ubuntu version
    if ! command -v lsb_release >/dev/null 2>&1; then
        echo "⚠️ Cannot determine Ubuntu version"
    else
        local ubuntu_version
        ubuntu_version=$(lsb_release -rs)
        echo "✅ Ubuntu $ubuntu_version detected"
        
        # Warn for older versions
        if [[ "${ubuntu_version%%.*}" -lt 20 ]]; then
            echo "⚠️ Ubuntu 20.04+ recommended for best compatibility"
        fi
    fi
    
    # Check available disk space (require at least 2GB)
    local available_space
    available_space=$(df ~ | awk 'NR==2 {print $4}')
    if [[ "$available_space" -lt 2097152 ]]; then
        echo "❌ Insufficient disk space. At least 2GB required."
        return 1
    fi
    
    echo "✅ System requirements check passed"
    return 0
}

# Function to clean old cache files (older than 7 days)
clean_cache() {
    echo "🧹 Cleaning old cache files..."
    find "$CACHE_DIR" -type f -mtime +7 -delete 2>/dev/null || true
    echo "✅ Cache cleanup completed"
}

# Function to get latest version from GitHub releases
get_latest_github_version() {
    local repo="$1"
    local version
    version=$(curl -s "https://api.github.com/repos/$repo/releases/latest" | grep -o '"tag_name": "[^"]*' | grep -o '[^"]*$' | sed 's/^v//')
    echo "$version"
}