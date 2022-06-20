#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Ignore Network Interruption
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔕

# Documentation:
# @raycast.description Mute the network interruptions dialog
# @raycast.author Kieran O'Brien
# @raycast.authorURL https://github.com/k-obrien/

try
	tell application "System Events" to tell process "loginwindow"
		set frontmost to true
		click button "Ignore" of window 1
	end tell
end try
