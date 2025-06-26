#!/bin/bash
# Structured logging with progress indicators

set -euo pipefail

LOG_FILE="$HOME/.cache/dotfiles/install.log"
PROGRESS_FILE="$HOME/.cache/dotfiles/progress.json"

mkdir -p "$(dirname "$LOG_FILE")"

# Initialize progress tracking
init_progress() {
    local total_steps="$1"
    cat > "$PROGRESS_FILE" <<EOF
{
  "total_steps": $total_steps,
  "current_step": 0,
  "start_time": "$(date -Iseconds)",
  "steps": []
}
EOF
}

# Update progress
update_progress() {
    local step_name="$1"
    local status="$2"  # starting, completed, failed
    
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        init_progress 10
    fi
    
    local current_time
    current_time=$(date -Iseconds)
    
    # Read current progress
    local current_step
    current_step=$(jq -r '.current_step' "$PROGRESS_FILE")
    
    if [[ "$status" == "starting" ]]; then
        current_step=$((current_step + 1))
    fi
    
    # Update progress file
    jq --arg step "$step_name" \
       --arg status "$status" \
       --arg time "$current_time" \
       --arg current "$current_step" \
       '.current_step = ($current | tonumber) | 
        .steps += [{"name": $step, "status": $status, "time": $time}]' \
       "$PROGRESS_FILE" > "${PROGRESS_FILE}.tmp" && mv "${PROGRESS_FILE}.tmp" "$PROGRESS_FILE"
    
    # Calculate and display progress
    local total_steps
    total_steps=$(jq -r '.total_steps' "$PROGRESS_FILE")
    local progress_percent
    progress_percent=$(( (current_step * 100) / total_steps ))
    
    case "$status" in
        "starting")
            log_info "🚀 Starting: $step_name [$current_step/$total_steps - ${progress_percent}%]"
            ;;
        "completed")
            log_success "✅ Completed: $step_name [$current_step/$total_steps - ${progress_percent}%]"
            ;;
        "failed")
            log_error "❌ Failed: $step_name [$current_step/$total_steps - ${progress_percent}%]"
            ;;
    esac
    
    # Visual progress bar
    show_progress_bar "$progress_percent"
}

# Show progress bar
show_progress_bar() {
    local percent="$1"
    local bar_length=50
    local filled_length=$((percent * bar_length / 100))
    local empty_length=$((bar_length - filled_length))
    
    printf "\r["
    printf "%*s" "$filled_length" | tr ' ' '='
    printf "%*s" "$empty_length" | tr ' ' '-'
    printf "] %d%%\n" "$percent"
}

# Logging functions with timestamps
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() {
    log_message "INFO" "$1"
}

log_success() {
    log_message "SUCCESS" "$1"
}

log_warning() {
    log_message "WARNING" "$1"
}

log_error() {
    log_message "ERROR" "$1"
}

log_debug() {
    if [[ "${DEBUG:-false}" == "true" ]]; then
        log_message "DEBUG" "$1"
    fi
}

# Function to show installation summary
show_summary() {
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        log_warning "No progress file found"
        return 1
    fi
    
    echo ""
    echo "📊 Installation Summary"
    echo "======================"
    
    local start_time end_time
    start_time=$(jq -r '.start_time' "$PROGRESS_FILE")
    end_time=$(date -Iseconds)
    
    echo "Start time: $start_time"
    echo "End time: $end_time"
    
    local completed_count failed_count
    completed_count=$(jq '[.steps[] | select(.status == "completed")] | length' "$PROGRESS_FILE")
    failed_count=$(jq '[.steps[] | select(.status == "failed")] | length' "$PROGRESS_FILE")
    
    echo "Completed steps: $completed_count"
    echo "Failed steps: $failed_count"
    
    if [[ "$failed_count" -gt 0 ]]; then
        echo ""
        echo "❌ Failed steps:"
        jq -r '.steps[] | select(.status == "failed") | "  - " + .name' "$PROGRESS_FILE"
    fi
    
    echo ""
    if [[ "$failed_count" -eq 0 ]]; then
        echo "🎉 All installations completed successfully!"
    else
        echo "⚠️ Some installations failed. Check the log for details."
    fi
}

# Clean old log files
clean_logs() {
    find "$(dirname "$LOG_FILE")" -name "*.log" -mtime +7 -delete 2>/dev/null || true
    log_info "🧹 Cleaned old log files"
}