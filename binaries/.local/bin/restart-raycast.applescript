#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Restart Raycast
# @raycast.mode silent

# Documentation:
# @raycast.description Quit and restart Raycast
# @raycast.author Kieran O'Brien
# @raycast.authorURL https://github.com/k-obrien/

quit app "Raycast"
repeat until app "Raycast" is not running
    delay 1
end repeat
launch app "Raycast"
