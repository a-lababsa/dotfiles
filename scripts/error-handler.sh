#!/bin/bash
# Error handling and rollback utilities

set -euo pipefail

ROLLBACK_LOG="$HOME/.cache/dotfiles/rollback.log"
BACKUP_DIR="$HOME/.cache/dotfiles/backup"

mkdir -p "$(dirname "$ROLLBACK_LOG")" "$BACKUP_DIR"

# Function to log rollback actions
log_rollback_action() {
    local action="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $action" >> "$ROLLBACK_LOG"
}

# Function to backup a file before modification
backup_file() {
    local file="$1"
    local backup_name="$2"
    
    if [[ -f "$file" ]]; then
        local backup_path="$BACKUP_DIR/${backup_name}_$(date +%s)"
        cp "$file" "$backup_path"
        log_rollback_action "BACKUP: $file -> $backup_path"
        echo "$backup_path"
    fi
}

# Function to backup a directory
backup_directory() {
    local dir="$1"
    local backup_name="$2"
    
    if [[ -d "$dir" ]]; then
        local backup_path="$BACKUP_DIR/${backup_name}_$(date +%s)"
        cp -r "$dir" "$backup_path"
        log_rollback_action "BACKUP_DIR: $dir -> $backup_path"
        echo "$backup_path"
    fi
}

# Function to restore from backup
restore_backup() {
    local backup_path="$1"
    local original_path="$2"
    
    if [[ -f "$backup_path" ]]; then
        cp "$backup_path" "$original_path"
        log_rollback_action "RESTORE: $backup_path -> $original_path"
        echo "✅ Restored $original_path"
    elif [[ -d "$backup_path" ]]; then
        rm -rf "$original_path"
        cp -r "$backup_path" "$original_path"
        log_rollback_action "RESTORE_DIR: $backup_path -> $original_path"
        echo "✅ Restored directory $original_path"
    else
        echo "❌ Backup not found: $backup_path"
        return 1
    fi
}

# Function to handle installation failures
handle_installation_failure() {
    local component="$1"
    local error_message="$2"
    
    echo "❌ Installation failed for $component: $error_message"
    log_rollback_action "FAILURE: $component - $error_message"
    
    # Offer rollback options
    echo ""
    echo "🔄 Rollback options:"
    echo "1. Continue with other installations"
    echo "2. Rollback recent changes and exit"
    echo "3. View rollback log"
    
    read -p "Choose an option [1-3]: " choice
    
    case "$choice" in
        1)
            echo "⏭️ Continuing with remaining installations..."
            return 0
            ;;
        2)
            echo "🔄 Starting rollback process..."
            perform_rollback
            exit 1
            ;;
        3)
            echo "📋 Recent rollback log entries:"
            tail -10 "$ROLLBACK_LOG"
            handle_installation_failure "$component" "$error_message"
            ;;
        *)
            echo "❌ Invalid choice. Exiting."
            exit 1
            ;;
    esac
}

# Function to perform rollback
perform_rollback() {
    echo "🔄 Performing rollback of recent changes..."
    
    if [[ ! -f "$ROLLBACK_LOG" ]]; then
        echo "⚠️ No rollback log found"
        return 0
    fi
    
    # Read rollback log and restore backups
    while IFS= read -r line; do
        if [[ "$line" == *"BACKUP:"* ]]; then
            local backup_info
            backup_info=$(echo "$line" | sed 's/.*BACKUP: //')
            local original_path
            original_path=$(echo "$backup_info" | cut -d' ' -f1)
            local backup_path
            backup_path=$(echo "$backup_info" | cut -d' ' -f3)
            
            if [[ -f "$backup_path" ]]; then
                restore_backup "$backup_path" "$original_path"
            fi
        elif [[ "$line" == *"BACKUP_DIR:"* ]]; then
            local backup_info
            backup_info=$(echo "$line" | sed 's/.*BACKUP_DIR: //')
            local original_path
            original_path=$(echo "$backup_info" | cut -d' ' -f1)
            local backup_path
            backup_path=$(echo "$backup_info" | cut -d' ' -f3)
            
            if [[ -d "$backup_path" ]]; then
                restore_backup "$backup_path" "$original_path"
            fi
        fi
    done < "$ROLLBACK_LOG"
    
    echo "✅ Rollback completed"
}

# Function to clean old backups (older than 30 days)
clean_old_backups() {
    echo "🧹 Cleaning old backups..."
    find "$BACKUP_DIR" -type f -mtime +30 -delete 2>/dev/null || true
    find "$BACKUP_DIR" -type d -empty -delete 2>/dev/null || true
    echo "✅ Backup cleanup completed"
}

# Trap to handle script interruption
trap 'echo "⚠️ Installation interrupted. Run '\''task rollback'\'' to undo recent changes."' INT TERM