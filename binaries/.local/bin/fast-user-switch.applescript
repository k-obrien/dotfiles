#!/usr/bin/osascript

tell application "System Events"
	set currentUser to full name of current user
	tell its application process "Control Centre"
		click menu bar item 3 of menu bar 1
		click first button of (buttons whose name is not currentUser) of group 1 of window "Control Centre"
	end tell
end tell
