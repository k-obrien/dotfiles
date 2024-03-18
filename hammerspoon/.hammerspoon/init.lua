-- Set the console color scheme
hs.console.darkMode(true)
hs.console.consolePrintColor({ green = 1 })
hs.console.consoleCommandColor({ white = 1 })
hs.console.consoleResultColor({ white = 0.8 })

-- Set alert position and style
hs.alert.defaultStyle.atScreenEdge = 2
hs.alert.defaultStyle.textFont = "Menlo"
hs.alert.defaultStyle.textSize = 24
hs.alert.defaultStyle.strokeColor = { white = 0, alpha = 0 }
hs.hotkey.alertDuration = 0

-- Enable auto-reload on configuration change
-- Requires ReloadConfiguration Spoon
if hs.spoons.isInstalled("ReloadConfiguration") then
    hs.loadSpoon("ReloadConfiguration")
    spoon.ReloadConfiguration:start()
end

-- Global modifier key; assigned to Caps Lock
modifier = { "ctrl", "cmd", "alt", "shift" }

-- >>> Apply a predefined window layout
function applyWindowLayout()
    local externalScreen = "LG HDR WQHD+"
    local internalScreen = "Built-in Retina Display"
    local numberOfScreens = #hs.screen.allScreens()

    local firefoxPos = hs.application.get("Android Studio") and { x = 0, y = 0, w = 0.35, h = 1 } or { x = 0.25, y = 0, w = 0.5, h = 1 }
    
    local dualScreenLayout = {
        { "Firefox", nil, externalScreen, firefoxPos, nil, nil },
        { "Android Studio", nil, externalScreen, { x = 0.35, y = 0, w = 0.65, h = 1 }, nil, nil },
        { "Slack", nil, internalScreen, hs.layout.maximized, nil, nil },
        { "Outlook", nil, internalScreen, hs.layout.maximized, nil, nil }
    }
    
    local singleScreenLayout = {
        { "Firefox", nil, internalScreen, hs.layout.maximized, nil, nil },
        { "Android Studio", nil, internalScreen, hs.layout.maximized, nil, nil },
        { "Slack", nil, internalScreen, hs.layout.maximized, nil, nil },
        { "Outlook", nil, internalScreen, hs.layout.maximized, nil, nil }
    }
    
    hs.layout.apply(numberOfScreens == 1 and singleScreenLayout or dualScreenLayout)
end

screenWatcher = hs.screen.watcher.new(applyWindowLayout)
hs.hotkey.bind(modifier, "l", "Layout Windows", applyWindowLayout)
-- <<<

-- >>> Toggle mute on Slack and Teams
function toggleMute() 
    local modifier = {"cmd", "shift"}
    local teams = hs.application.get("com.microsoft.teams2")
    if teams then hs.eventtap.keyStroke(modifier, "m", 0, teams) end
    local slack = hs.application.get("com.tinyspeck.slackmacgap")
    if slack then hs.eventtap.keyStroke(modifier, "space", 0, slack) end
end

hs.hotkey.bind(modifier, "a", "Toggle Mute", toggleMute)
-- <<<

-- Call functions on system state changes
-- Requires StateActor Spoon
if hs.spoons.isInstalled("StateActor") then
    hs.loadSpoon("StateActor")
    local actionsForStates = { applyWindowLayout }
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
    postureMenuBarItem:setTitle(sitting and "—" or "⏐")
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
    ):schedule(os.time() + hs.timer.minutes(30))
end

if postureMenuBarItem then
    postureMenuBarItem:setClickCallback(postureClicked)
    setPosture(sitting)
end
-- <<<

-- >>> Show Phonetic Alphabet
local function showPhoneticAlphabet()
    local alphabet = "A\tAlpha\t\t\t" ..
                     "N\tNovember\n" ..
                     "B\tBravo\t\t\t" ..
                     "O\tOscar\n" ..
                     "C\tCharlie\t\t" ..
                     "P\tPapa\n" ..
                     "D\tDelta\t\t\t" ..
                     "Q\tQuebec\n" ..
                     "E\tEcho\t\t\t" ..
                     "R\tRomeo\n" ..
                     "F\tFoxtrot\t\t" ..
                     "S\tSierra\n" ..
                     "G\tGolf\t\t\t" ..
                     "T\tTango\n" ..
                     "H\tHotel\t\t\t" ..
                     "U\tUniform\n" ..
                     "I\tIndia\t\t\t" ..
                     "V\tVictor\n" ..
                     "J\tJuliet\t\t" ..
                     "W\tWhisky\n" ..
                     "K\tKilo\t\t\t" ..
                     "X\tX-Ray\n" ..
                     "L\tLima\t\t\t" ..
                     "Y\tYankee\n" ..
                     "M\tMike\t\t\t" ..
                     "Z\tZulu\n"
    hs.alert.show(alphabet:sub(1, -2), "infinite")
end

hs.hotkey.bind(modifier, "p", "Phonetic Alphabet", showPhoneticAlphabet, hs.alert.closeAll)
-- <<<

-- Defeat paste-blocking
hs.hotkey.bind(modifier, "v", "Paste clipboard contents", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)
