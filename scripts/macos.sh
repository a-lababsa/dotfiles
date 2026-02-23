#!/bin/bash

# macOS System Configuration
# Based on https://mths.be/macos

# Source shared utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"

# Close any open System Preferences panes, to prevent them from overriding settings
osascript -e 'tell application "System Preferences" to quit'

print_status "Applying comprehensive macOS configurations..."

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Set sidebar icon size to medium
# defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# # Always show scrollbars
# defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# # Increase window resize speed for Cocoa applications
# defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# # Expand save panel by default
# defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
# defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# # Expand print panel by default
# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# # Save to disk (not to iCloud) by default
# defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# # Automatically quit printer app once the print jobs complete
# defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# # Disable the "Are you sure you want to open this application?" dialog
# defaults write com.apple.LaunchServices LSQuarantine -bool false

# # Disable Resume system-wide
# defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# # Disable automatic termination of inactive apps
# defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

# # Disable automatic capitalization as it's annoying when typing code
# defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# # Disable smart dashes as they're annoying when typing code
# defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# # Disable automatic period substitution as it's annoying when typing code
# defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# # Disable smart quotes as they're annoying when typing code
# defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# # Disable auto-correct
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# ###############################################################################
# # Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
# ###############################################################################

# # Trackpad: enable tap to click for this user and for the login screen
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
# defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# # Trackpad: map bottom right corner to right-click
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
# defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# # Disable "natural" (Lion-style) scrolling
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# # Enable full keyboard access for all controls
# defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# # Disable press-and-hold for keys in favor of key repeat
# defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# # Set a blazingly fast keyboard repeat rate
# defaults write NSGlobalDomain KeyRepeat -int 1
# defaults write NSGlobalDomain InitialKeyRepeat -int 10

# ###############################################################################
# # Energy saving                                                               #
# ###############################################################################

# # Enable lid wakeup
# sudo pmset -a lidwake 1

# # Restart automatically on power loss
# sudo pmset -a autorestart 1

# # Sleep the display after 15 minutes
# sudo pmset -a displaysleep 15

# # Disable machine sleep while charging
# sudo pmset -c sleep 0

# # Set machine sleep to 5 minutes on battery
# sudo pmset -b sleep 5

# ###############################################################################
# # Screen                                                                      #
# ###############################################################################

# # Require password immediately after sleep or screen saver begins
# defaults write com.apple.screensaver askForPassword -int 1
# defaults write com.apple.screensaver askForPasswordDelay -int 0

# # Save screenshots to the desktop
# defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# # Save screenshots in PNG format
# defaults write com.apple.screencapture type -string "png"

# # Disable shadow in screenshots
# defaults write com.apple.screencapture disable-shadow -bool true

# ###############################################################################
# # Finder                                                                      #
# ###############################################################################

# # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
# defaults write com.apple.finder QuitMenuItem -bool true

# # Finder: disable window animations and Get Info animations
# defaults write com.apple.finder DisableAllAnimations -bool true

# # Finder: show hidden files by default
# defaults write com.apple.finder AppleShowAllFiles -bool true

# # Finder: show all filename extensions
# defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# # Finder: show status bar
# defaults write com.apple.finder ShowStatusBar -bool true

# # Finder: show path bar
# defaults write com.apple.finder ShowPathbar -bool true

# # Display full POSIX path as Finder window title
# defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# # Keep folders on top when sorting by name
# defaults write com.apple.finder _FXSortFoldersFirst -bool true

# # When performing a search, search the current folder by default
# defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# # Disable the warning when changing a file extension
# defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# # Avoid creating .DS_Store files on network or USB volumes
# defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# # Use list view in all Finder windows by default
# defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# # Disable the warning before emptying the Trash
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

# # Show the ~/Library folder
# chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library 2>/dev/null

# # Show the /Volumes folder
# sudo chflags nohidden /Volumes

# ###############################################################################
# # Dock, Dashboard, and hot corners                                            #
# ###############################################################################

# # Set the icon size of Dock items to 36 pixels
# defaults write com.apple.dock tilesize -int 36

# # Change minimize/maximize window effect
# defaults write com.apple.dock mineffect -string "scale"

# # Minimize windows into their application's icon
# defaults write com.apple.dock minimize-to-application -bool true

# # Show indicator lights for open applications in the Dock
# defaults write com.apple.dock show-process-indicators -bool true

# # Don't animate opening applications from the Dock
# defaults write com.apple.dock launchanim -bool false

# # Speed up Mission Control animations
# defaults write com.apple.dock expose-animation-duration -float 0.1

# # Don't automatically rearrange Spaces based on most recent use
# defaults write com.apple.dock mru-spaces -bool false

# # Remove the auto-hiding Dock delay
# defaults write com.apple.dock autohide-delay -float 0

# # Remove the animation when hiding/showing the Dock
# defaults write com.apple.dock autohide-time-modifier -float 0

# # Automatically hide and show the Dock
# defaults write com.apple.dock autohide -bool true

# # Make Dock icons of hidden applications translucent
# defaults write com.apple.dock showhidden -bool true

# # Don't show recent applications in Dock
# defaults write com.apple.dock show-recents -bool false

# # Hot corners
# # Top left screen corner → Mission Control
# defaults write com.apple.dock wvous-tl-corner -int 2
# defaults write com.apple.dock wvous-tl-modifier -int 0
# # Top right screen corner → Desktop
# defaults write com.apple.dock wvous-tr-corner -int 4
# defaults write com.apple.dock wvous-tr-modifier -int 0
# # Bottom left screen corner → Start screen saver
# defaults write com.apple.dock wvous-bl-corner -int 5
# defaults write com.apple.dock wvous-bl-modifier -int 0

# ###############################################################################
# # Safari & WebKit                                                             #
# ###############################################################################

# # Privacy: don't send search queries to Apple
# defaults write com.apple.Safari UniversalSearchEnabled -bool false
# defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# # Show the full URL in the address bar
# defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

# # Set Safari's home page to about:blank for faster loading
# defaults write com.apple.Safari HomePage -string "about:blank"

# # Prevent Safari from opening 'safe' files automatically after downloading
# defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# # Hide Safari's bookmarks bar by default
# defaults write com.apple.Safari ShowFavoritesBar -bool false

# # Enable Safari's debug menu
# defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# # Enable the Develop menu and the Web Inspector in Safari
# defaults write com.apple.Safari IncludeDevelopMenu -bool true
# defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true

# # Enable "Do Not Track"
# defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# ###############################################################################
# # Time Machine                                                                #
# ###############################################################################

# # Prevent Time Machine from prompting to use new hard drives as backup volume
# defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# ###############################################################################
# # Activity Monitor                                                            #
# ###############################################################################

# # Show the main window when launching Activity Monitor
# defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# # Visualize CPU usage in the Activity Monitor Dock icon
# defaults write com.apple.ActivityMonitor IconType -int 5

# # Show all processes in Activity Monitor
# defaults write com.apple.ActivityMonitor ShowCategory -int 0

# # Sort Activity Monitor results by CPU usage
# defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
# defaults write com.apple.ActivityMonitor SortDirection -int 0

# ###############################################################################
# # TextEdit and other apps                                                     #
# ###############################################################################

# # Use plain text mode for new TextEdit documents
# defaults write com.apple.TextEdit RichText -int 0

# # Open and save files as UTF-8 in TextEdit
# defaults write com.apple.TextEdit PlainTextEncoding -int 4
# defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# ###############################################################################
# # Mac App Store                                                               #
# ###############################################################################

# # Enable the automatic update check
# defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# # Check for software updates daily, not just once per week
# defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# # Download newly available updates in background
# defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# # Install System data files & security updates
# defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# # Turn on app auto-update
# defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

# Prevent Photos from opening automatically when devices are plugged in
# defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

print_status "Restarting affected applications..."

for app in "Activity Monitor" \
    "Dock" \
    "Finder" \
    "Safari" \
    "SystemUIServer"; do
    killall "${app}" &> /dev/null 2>&1
done

print_status "macOS configuration applied!"
print_warning "Some changes require a logout/restart to take effect."