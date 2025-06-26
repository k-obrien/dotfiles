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

local function loadSpoon(spoon)
    local spoonIsInstalled = hs.spoons.isInstalled(spoon)

    if hs.spoons.isInstalled(spoon) then
        hs.loadSpoon(spoon)
    end

    return spoonIsInstalled
end

-- Enable auto-reload on configuration change
-- Requires ReloadConfiguration Spoon
if loadSpoon("ReloadConfiguration") then
    spoon.ReloadConfiguration:start()
end

-- Global modifier key; assigned to Caps Lock
modifier = { "ctrl", "cmd", "alt", "shift" }

-- >>> Apply a predefined window layout
local function applyWindowLayout()
    local internalScreen = "Built-in Retina Display"
    local primaryScreen = hs.screen.primaryScreen():name()

    local browserPos = hs.application.get("Android Studio") and { x = 0, y = 0, w = 0.35, h = 1 } or { x = 0.25, y = 0, w = 0.5, h = 1 }
    
    local notebookLayout = {
        { "Firefox", nil, primaryScreen, hs.layout.maximized, nil, nil },
        { "Chrome", nil, primaryScreen, hs.layout.maximized, nil, nil },
        { "Android Studio", nil, primaryScreen, hs.layout.maximized, nil, nil }
    }
    
    local desktopLayout = {
        { "Firefox", nil, primaryScreen, browserPos, nil, nil },
        { "Chrome", nil, primaryScreen, browserPos, nil, nil },
        { "Android Studio", nil, primaryScreen, { x = 0.35, y = 0, w = 0.65, h = 1 }, nil, nil }
    }
    
    hs.layout.apply(primaryScreen == internalScreen and notebookLayout or desktopLayout)
end

hs.hotkey.bind(modifier, "l", "Layout Windows", applyWindowLayout)
-- <<<

-- >>> Toggle mute on Slack and Teams
local function toggleChatMicMute() 
    local modifier = {"cmd", "shift"}
    local teams = hs.application.get("com.microsoft.teams2")
    if teams then hs.eventtap.keyStroke(modifier, "m", 0, teams) end
    local slack = hs.application.get("com.tinyspeck.slackmacgap")
    if slack then hs.eventtap.keyStroke(modifier, "space", 0, slack) end
end

hs.hotkey.bind(modifier, "a", "Toggle Chat Microphone Mute", toggleChatMicMute)
-- <<<

-- >>> Sit/Stand Reminder
sitStandTimer = nil

local function stopSitStandTimer()
    if sitStandTimer then
        sitStandTimer:stop()
        sitStandTimer = nil
    end
end

frame = nil

function resetSitStandScreenEffects()
    if frame then
        frame:hide(0.5)
        frame:delete()
        frame = nil
    end
end

sitStandMenuBarItem = nil

local function stopSitStandReminder()
    stopSitStandTimer()
    resetSitStandScreenEffects()
    sitStandMenuBarItem:delete()
    sitStandMenuBarItem = nil
end

sitStandIntervalInSeconds = hs.timer.minutes(30)

local function startSitStandReminder()
    resetSitStandScreenEffects()
    frame = hs.drawing.rectangle(hs.screen.primaryScreen():fullFrame())
    frame:setFillColor({ ["red"] = 0, ["blue"] = 0, ["green"] = 1, ["alpha"] = 0.3 })
    frame:setFill(true)
    frame:bringToFront(true)

    stopSitStandTimer()
    sitStandTimer = hs.timer.doAfter(
        sitStandIntervalInSeconds,
        function()
            stopSitStandTimer()
            frame:show(0.5)
        end
    )

    if not sitStandMenuBarItem then
        sitStandMenuBarItem = hs.menubar.new()
        sitStandMenuBarItem:setTitle("⇅")
        sitStandMenuBarItem:setClickCallback(stopSitStandReminder)
    end
end

hs.hotkey.bind(modifier, "d", startSitStandReminder)
-- <<<

-- >>> Show Phonetic Alphabet
local function showPhoneticAlphabet()
    local alphabet = hs.styledtext.getStyledTextFromFile("phonetic-alphabet.html", "html")
    hs.alert.show(alphabet, { atScreenEdge = 0 }, "infinite")
end

hs.hotkey.bind(modifier, "p", "Phonetic Alphabet", showPhoneticAlphabet, hs.alert.closeAll)
-- <<<

-- >>> Defeat paste-blocking
hs.hotkey.bind(modifier, "v", "Paste clipboard contents", function() hs.eventtap.keyStrokes(hs.pasteboard.getContents()) end)
-- <<<

-- >>> Call functions on system state changes
screenWatcher = hs.screen.watcher.new(applyWindowLayout)

-- Requires StateActor Spoon
if loadSpoon("StateActor") then
    local actionsForStates = { applyWindowLayout }
    spoon.StateActor:bindActions({
        sessionDidBecomeActive = actionsForStates,
        screensDidUnlock = actionsForStates,
        screensDidWake = actionsForStates,
        systemDidWake = actionsForStates
    })
    spoon.StateActor:start()
end
-- <<<

-- >>> Move mouse cursor to centre of focused window
if loadSpoon("MouseFollowsFocus") then
    spoon.MouseFollowsFocus:start()
end
-- <<<

if loadSpoon("MouseCircle") then
    spoon.MouseCircle:bindHotkeys({ show = { modifier, "q" } })
end
