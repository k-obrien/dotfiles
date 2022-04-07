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

-- Dismiss network interruption warning
function dismissNetworkInterruptionWarning()
	local window = hs.window.get(1692)

	if window and window:application():name() == "loginwindow" and window:id() == 1692 then
		hs.osascript.applescriptFromFile("~/.scripts/ignore-network-interruption.applescript")
	end
end

hs.window.filter.new(true):subscribe(
	hs.window.filter.windowCreated,
	function(window, appName, event) dismissNetworkInterruptionWarning() end,
	true
)

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
	local actionsForStates = { muteAudioOutputDevice, applyWindowLayout, dismissNetworkInterruptionWarning }
	spoon.StateActor:bindActions({
		sessionDidBecomeActive = actionsForStates,
		screensDidUnlock = actionsForStates,
		screensDidWake = actionsForStates,
		systemDidWake = actionsForStates
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

-- Apply a predefined window layout
hs.hotkey.bind(modifier, "l", "Layout Windows", applyWindowLayout)

-- Defeat paste-blocking
hs.hotkey.bind(modifier, "v", "Paste clipboard contents", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)
