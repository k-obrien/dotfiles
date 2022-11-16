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

function applyWindowLayout()
    local externalScreen = "LG HDR WQHD+"
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

screenWatcher = hs.screen.watcher.new(applyWindowLayout)

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
    ):schedule(os.time() + hs.timer.hours(1))
end

if postureMenuBarItem then
    postureMenuBarItem:setClickCallback(postureClicked)
    setPosture(sitting)
end
-- <<<

-- Global modifier key; assigned to Caps Lock in Karabiner
modifier = { "ctrl", "cmd", "alt", "shift" }

-- >>> Show hotkey assignments
local function showHelp()
    local hotkeys = hs.hotkey.getHotkeys()
    local legend = ""

    for i = 1, #hotkeys do
        local msg = string.gsub(hotkeys[i].msg, ": ", ":\t", 1)
        if msg ~= hotkeys[i].idx then legend = legend .. msg .. "\n" end
    end

    legend = legend ..
             "\n" ..
             "⌥B:\tBelay current command\n" ..
             "⌥S:\tPrepend sudo to current or previous command\n" ..
             "⌥W:\tShow short description of app under cursor\n" ..
             "⌥H:\tShow manpage for app under cursor\n" ..
             "⌥L:\tList contents of directory under cursor or current directory\n" ..
             "⌥E:\tEdit command in editor\n" ..
             "⌥C:\tCapitalise first letter of word under cursor\n" ..
             "⌥U:\tCapitalise word under cursor\n" ..
             "^T:\tTranspose current and previous character\n" ..
             "⌥T:\tTranpose current and previous word\n" ..
             "^Z:\tUndo most recent line edit\n" ..
             "⌥/:\tRevert most recent undo of line edit\n\n" ..
             "^R:\t\tSearch command history\n" ..
             "^V:\t\tSearch environment variables\n" ..
             "^⌥F:\tSearch current directory\n" ..
             "^⌥L:\tSearch git log\n" ..
             "^⌥L:\tSearch git status\n" ..
             "^⌥P:\tSearch processes\n\n" ..
             "^[AE]:\tMove cursor to start/end of line\n" ..
             "⌥[←→]:\tMove cursor one inclusive word OR navigate directory stack\n" ..
             "⇧[←→]:\tMove cursor one exclusive word OR accept big word of autosuggestion\n" ..
             "⌥[↑↓]:\tSearch history for instances of original token under cursor\n"

    hs.alert.show(legend:sub(1, -2), "infinite")
end

hs.hotkey.bind(modifier, "a", showHelp, hs.alert.closeAll)
-- <<<

-- Apply a predefined window layout
hs.hotkey.bind(modifier, "l", "Layout Windows", applyWindowLayout)

-- Defeat paste-blocking
hs.hotkey.bind(modifier, "v", "Paste clipboard contents", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)

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
