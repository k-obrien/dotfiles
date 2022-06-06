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

	if window and window:application():name() == "loginwindow" then
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

	local firefoxPos = hs.application.get("Android Studio") and { x = 0, y = 0, w = 0.35, h = 1 } or { x = 0.25, y = 0, w = 0.5, h = 1 }
    
    local dualScreenLayout = {
        { "Firefox", nil, externalScreen, firefoxPos, nil, nil },
        { "Android Studio", nil, externalScreen, { x = 0.35, y = 0, w = 0.65, h = 1 }, nil, nil },
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

-- Call functions on system state changes
-- Requires StateActor Spoon
if hs.spoons.isInstalled("StateActor") then
	hs.loadSpoon("StateActor")
	local actionsForStates = { applyWindowLayout, dismissNetworkInterruptionWarning }
	spoon.StateActor:bindActions({
		sessionDidBecomeActive = actionsForStates,
		screensDidUnlock = actionsForStates,
		screensDidWake = actionsForStates,
		systemDidWake = actionsForStates
	})
	spoon.StateActor:start()
end

-- >>> Sit/Stand menu item and notification
postureMenuBarItem = hs.menubar.new()
sitting = true

function setPosture(sitting)
    postureMenuBarItem:setTitle(sitting and "SITTING" or "STANDING")
end

function cancelNotifications()
    hs.notify.withdrawAll()
    hs.notify.withdrawAllScheduled()
end

function postureClicked()
    if (sitting) then
        sitting = false
    else
        sitting = true
    end
    
    setPosture(sitting)
    cancelNotifications()
    hs.notify.new(
        cancelNotifications,
        { 
            title = "Change Posture", 
            informativeText = sitting and "Stand up" or "Sit down", 
            withdrawAfter = 0
        }
    ):schedule(os.time() + hs.timer.hours(1))
end

if postureMenuBarItem then
    postureMenuBarItem:setClickCallback(postureClicked)
    setPosture(sitting)
end
-- <<<

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
