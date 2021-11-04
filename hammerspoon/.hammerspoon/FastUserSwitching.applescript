tell application "System Events"
	set currentUser to full name of current user
	
	tell its application process "ControlCenter"
		tell its menu bar 1
			click its menu bar item "User"
		end tell
		
		tell its window "Control Centre"
			tell its group 1
				click first button of (buttons whose name is not currentUser)
			end tell
		end tell
	end tell
end tell
