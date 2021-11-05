local partial = hs.fnutils.partial

-- Set the console color scheme
hs.console.darkMode(true)
hs.console.consolePrintColor({ green = 1 })
hs.console.consoleCommandColor({ white = 1 })
hs.console.consoleResultColor({ white = 0.8 })

-- Set alert position and style
hs.alert.defaultStyle["strokeColor"] = { white = 0, alpha = 0 }
hs.alert.defaultStyle["textSize"] = 24

-- Enable auto-reload on configuration change
-- Requires ReloadConfiguration Spoon
if hs.spoons.isInstalled("ReloadConfiguration") then
	hs.loadSpoon("ReloadConfiguration")
	spoon.ReloadConfiguration:start()
end

function applyWindowLayout()
    local externalScreen = "LG ULTRAWIDE"
    local internalScreen = "Built-in Retina Display"
    local numberOfScreens = #hs.screen.allScreens()
    
    local dualScreenLayout = {
        { "Firefox", nil, externalScreen, { 0, 0, 0.35, 1 }, nil, nil },
        { "Android Studio", nil, externalScreen, { 0.35, 0, 0.65, 1 }, nil, nil },
        { "Slack", nil, internalScreen, hs.layout.maximized, nil, nil }
    }
    
    local singleScreenLayout = {
        { "Firefox", nil, internalScreen, hs.layout.maximized, nil, nil },
        { "Android Studio", nil, internalScreen, hs.layout.maximized, nil, nil },
        { "Slack", nil, internalScreen, hs.layout.maximized, nil, nil }
    }
    
    hs.layout.apply(numberOfScreens == 1 and singleScreenLayout or dualScreenLayout)
end

hs.screen.watcher.new(applyWindowLayout)

function muteAudioOutputDevice()
	local preferredDevice = "MacBook Pro Speakers"
	local device = hs.audiodevice.findDeviceByName(preferredDevice)
	
	if device == nil then
		hs.alert.show("Could not find device: " .. preferredDevice)
	else
		local currentUser = hs.caffeinate.sessionProperties()["kCGSSessionUserNameKey"]
		device:setOutputMuted(currentUser:find(".", 1, true) == nil)
	end
end

-- Call functions on system state changes
-- Requires StateActor Spoon
if hs.spoons.isInstalled("StateActor") then
	hs.loadSpoon("StateActor")
	spoon.StateActor:bindActions({
		sessionDidBecomeActive = { partial(muteAudioOutputDevice) },
		screensDidUnlock = { partial(applyWindowLayout) }
	})
	spoon.StateActor:start()
end

-- Global modifier key; assigned to Caps Lock in Karabiner
local modifier = { "ctrl", "cmd", "alt", "shift" }

-- Show hotkey assignments
local function showHelp()
    local hotkeys = hs.hotkey.getHotkeys()
    local legend = ""

    for i = 1, #hotkeys do
        local msg = string.gsub(hotkeys[i].msg, ": ", ":\t", 1)
        if msg ~= hotkeys[i].idx then legend = legend .. msg .. "\n" end
    end

    hs.alert.show(legend:sub(1, -2), 3600)
end

hs.hotkey.alertDuration = 0
hs.hotkey.bind(modifier, "a", showHelp, hs.alert.closeAll)

-- Switch user
hs.hotkey.bind(modifier, "s", "Switch user", partial(hs.osascript.applescriptFromFile, "FastUserSwitching.applescript"))

-- Apply a predefined window layout
hs.hotkey.bind(modifier, "l", "Layout Windows", applyWindowLayout)

-- Open a terminal
hs.hotkey.bind(modifier, "t", "Terminal", partial(hs.application.launchOrFocus, "iTerm"))

-- Open a text editor
hs.hotkey.bind(modifier, "e", "Text Editor", partial(hs.application.launchOrFocus, "Visual Studio Code"))

-- Open Finder to home
hs.hotkey.bind(modifier, "f", "Finder", partial(hs.application.launchOrFocus, "Finder"))

-- Defeat paste-blocking
hs.hotkey.bind(modifier, "v", "Paste clipboard contents", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

-- Bind hotkeys to common window manipulation functions
-- Requires SmudgedGlass Spoon
if hs.spoons.isInstalled("SmudgedGlass") then
	hs.application.enableSpotlightForNameSearches(true)
	hs.loadSpoon("SmudgedGlass")
	spoon.SmudgedGlass:bindHotKeys({
		toggleGrid = { modifier, "`", message = "Toggle window grid" },
		windowMaximise = { modifier, "m", message = "Maximise window" },
		windowMaximiseCentre = { modifier, "u" },
		windowLeft = { modifier, "y" },
		windowLeftTop = { modifier, "7" },
		windowLeftBottom = { modifier, "h" },
		windowRight = { modifier, "i" },
		windowRightTop = { modifier, "9" },
		windowRightBottom = { modifier, "k" },
		windowCentre = { modifier, "c" },
		windowNorth = { modifier, "up" },
		windowSouth = { modifier, "down" },
		windowWest = { modifier, "left" },
		windowEast = { modifier, "right" },
		undo = { modifier, "z", message = "Undo last resize/move operation for focused window" }
	})
	spoon.SmudgedGlass:start()
end

-- Modally emulate a number pad
-- Requires NumPad Spoon
if hs.spoons.isInstalled("NumPad") then
	hs.loadSpoon("NumPad")
	spoon.NumPad:bindHotKeys({
		numLock = { modifier, "p", message = "Toggle modal number pad" },
		enter = { "space" },
		clear = { "escape" },
		zero = { "n" },
		one = { "h" },
		two = { "j" },
		three = { "k" },
		four = { "y" },
		five = { "u" },
		six = { "i" },
		seven = { "7" },
		eight = { "8" },
		nine = { "9" },
		decimal = { "m" },
		division = { "0" },
		multiplication = { "o" },
		substraction = { "l" },
		addition = { "," }
	})
end
