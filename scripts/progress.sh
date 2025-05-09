#!/bin/bash
# Progress bar function for shell scripts
# Usage: source progress.sh

# Variables for progress bar configuration
PROGRESS_BAR_WIDTH=50  # Width of the progress bar
PROGRESS_BAR_CHAR="█"  # Character used for the progress bar
PROGRESS_BG_CHAR="░"   # Background character for the progress bar
PROGRESS_COLOR="\e[32m"  # Default color (green)
PROGRESS_BG_COLOR="\e[90m"  # Background color (gray)
PROGRESS_RESET="\e[0m"  # Reset color code

# Initialize progress bar
init_progress() {
  local title="${1:-"Progress"}"
  local color="${2:-$PROGRESS_COLOR}"
  
  # Save cursor position
  tput sc
  
  # Print title
  echo -e "\n${color}${title}${PROGRESS_RESET}"
  
  # Print empty progress bar
  printf "${PROGRESS_BG_COLOR}"
  printf "%${PROGRESS_BAR_WIDTH}s" | tr " " "$PROGRESS_BG_CHAR"
  printf "${PROGRESS_RESET}"
  
  # Print percentage
  echo -e " 0%"
  
  # Return to start of progress bar
  tput rc
  tput cud1  # Move cursor down 1 line
}

# Update progress bar
update_progress() {
  local percent=$1
  local message="${2:-}"
  
  # Ensure percent is between 0-100
  [[ $percent -lt 0 ]] && percent=0
  [[ $percent -gt 100 ]] && percent=100
  
  # Calculate filled width
  local filled_width=$((percent * PROGRESS_BAR_WIDTH / 100))
  
  # Save cursor position
  tput sc
  
  # Move to progress bar line
  tput cud1
  
  # Draw progress bar
  printf "${PROGRESS_COLOR}"
  printf "%${filled_width}s" | tr " " "$PROGRESS_BAR_CHAR"
  printf "${PROGRESS_RESET}"
  
  # Draw background for remaining part
  local remaining_width=$((PROGRESS_BAR_WIDTH - filled_width))
  if [[ $remaining_width -gt 0 ]]; then
    printf "${PROGRESS_BG_COLOR}"
    printf "%${remaining_width}s" | tr " " "$PROGRESS_BG_CHAR"
    printf "${PROGRESS_RESET}"
  fi
  
  # Print percentage
  printf " %3d%%" $percent
  
  # Print message if provided
  if [[ -n "$message" ]]; then
    printf " - %s" "$message"
  fi
  
  # Clear to the end of line (in case previous message was longer)
  tput el
  
  # Restore cursor position
  tput rc
}

# Complete progress bar
complete_progress() {
  local message="${1:-"Complete!"}"
  
  # Update to 100%
  update_progress 100 "$message"
  
  # Move cursor past the progress bar for next output
  echo -e "\n"
}

# Create a spinner animation
SPINNER_CHARS=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
SPINNER_DELAY=0.1
SPINNER_POS=0

# Start spinner
start_spinner() {
  local message="${1:-"Processing..."}"
  
  # Save cursor position
  tput sc
  
  # Print initial spinner
  echo -e "\n${SPINNER_CHARS[0]} $message"
  
  # Save position for updates
  tput sc
  
  # Start spinner in background
  (
    while true; do
      SPINNER_POS=$(( (SPINNER_POS + 1) % ${#SPINNER_CHARS[@]} ))
      
      # Restore cursor position
      tput rc
      
      # Print updated spinner
      echo -e "${SPINNER_CHARS[$SPINNER_POS]} $message"
      
      # Save position for next update
      tput sc
      
      sleep $SPINNER_DELAY
    done
  ) &
  
  # Save spinner process ID
  SPINNER_PID=$!
}

# Stop spinner
stop_spinner() {
  local message="${1:-"Done!"}"
  
  # Kill spinner process
  kill $SPINNER_PID 2>/dev/null
  
  # Restore cursor position
  tput rc
  
  # Clear line and print completion message
  tput el
  echo -e "✓ $message"
}

# Usage example for progress bar
demo_progress() {
  init_progress "Installing components" "\e[36m"  # Cyan color
  
  for i in {0..100..10}; do
    update_progress $i "Step $((i/10)) of 10"
    sleep 0.5
  done
  
  complete_progress "All components installed successfully!"
}

# Usage example for spinner
demo_spinner() {
  start_spinner "Downloading packages..."
  sleep 3
  stop_spinner "Packages downloaded successfully!"
}

# Run demo if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Progress bar demonstration:"
  demo_progress
  
  echo "Spinner demonstration:"
  demo_spinner
fi