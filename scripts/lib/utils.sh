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