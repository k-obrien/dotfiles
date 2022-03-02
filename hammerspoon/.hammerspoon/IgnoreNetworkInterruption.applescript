try
	tell application "System Events" to tell process "loginwindow"
		set frontmost to true
		click button "Ignore" of window 1
	end tell
end try
