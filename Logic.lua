-- PaTiSuite: settings and the window list, without WoW API calls (tested in tests/logic_spec.lua).
-- A remote control only: it shows/hides the main windows other PaTi addons registered in _G.PaTiSuiteWindows
-- (PaTiShared). It holds no gameplay logic; no addon needs PaTiSuite.
local _, ns = ...
local Logic = {}
ns.Logic = Logic

Logic.SCHEMA = 1
Logic.SCALES = { 0.8, 0.9, 1, 1.1, 1.25, 1.5 }
Logic.ORDER = { "PaTiHeal", "PaTiAuras", "PaTiTank", "PaTiGroup", "PaTiQuest", "PaTiDungeon", "PaTiAlerts" }

-- Position (point, relativePoint, x, y) is written by the PaTiShared window, not listed here.
Logic.DEFAULTS = {
    opacity = 0.75,
    locked = false,
    scale = 1,
    language = "auto",
}

function Logic.Migrate(db)
    db = db or {}
    for key, value in pairs(Logic.DEFAULTS) do
        if db[key] == nil then db[key] = value end
    end
    db.schema = Logic.SCHEMA
    return db
end

function Logic.RestoreDefaults(db)
    for key, value in pairs(Logic.DEFAULTS) do db[key] = value end
    return db
end

-- Status colour of a window line: green while shown, grey while hidden (PaTi blue stays the suite accent).
function Logic.StateColor(shown)
    return shown and "Success" or "TextMuted"
end

-- "PaTiHeal" → "Heal".
function Logic.Label(name)
    return (name:gsub("^PaTi", ""))
end

-- The installed windows: { { name, frame } } in suite order, then any other registered PaTi window by name.
-- Only frames that can be shown/hidden count; `selfName` (the control panel) is left out.
function Logic.Entries(registry, selfName)
    local entries, listed = {}, {}
    local function add(name)
        local frame = type(registry) == "table" and registry[name]
        if name ~= selfName and not listed[name] and type(frame) == "table" and type(frame.SetShown) == "function"
            and type(frame.IsShown) == "function" then
            listed[name] = true
            entries[#entries + 1] = { name = name, frame = frame }
        end
    end
    for _, name in ipairs(Logic.ORDER) do add(name) end
    local others = {}
    for name in pairs(type(registry) == "table" and registry or {}) do
        if type(name) == "string" and not listed[name] then others[#others + 1] = name end
    end
    table.sort(others)
    for _, name in ipairs(others) do add(name) end
    return entries
end

-- Is the addon's window on? Uses the addon's own rule (IsSuiteShown) if it has one.
function Logic.IsShown(frame)
    local method = type(frame.IsSuiteShown) == "function" and frame.IsSuiteShown or frame.IsShown
    local ok, shown = pcall(method, frame)
    return ok and shown == true
end

-- Shows/hides through the addon's own rules (SetSuiteShown: e.g. blocked in combat for windows with secure
-- children). Without them, a protected frame is never touched in combat. Returns true if done.
function Logic.SetShown(frame, shown, inCombat)
    if type(frame.SetSuiteShown) == "function" then
        local ok, done = pcall(frame.SetSuiteShown, frame, shown)
        return ok and done ~= false
    end
    if inCombat and type(frame.IsProtected) == "function" and frame:IsProtected() then return false end
    return (pcall(frame.SetShown, frame, shown))
end

-- Show/hide all. Returns the names that could not be changed now (e.g. in combat).
function Logic.SetAll(entries, shown, inCombat)
    local blocked = {}
    for _, entry in ipairs(entries) do
        if Logic.IsShown(entry.frame) ~= shown and not Logic.SetShown(entry.frame, shown, inCombat) then
            blocked[#blocked + 1] = entry.name
        end
    end
    return blocked
end

-- What the single "all" button does now: true = show all (at least one window is hidden), false = hide all
-- (every window is shown). No windows: true (the button is disabled then).
function Logic.AllTarget(entries)
    for _, entry in ipairs(entries) do
        if not Logic.IsShown(entry.frame) then return true end
    end
    return #entries == 0
end

-- One click on a row: visible → hide, hidden → show. Returns true if done.
function Logic.Toggle(entry, inCombat)
    return Logic.SetShown(entry.frame, not Logic.IsShown(entry.frame), inCombat)
end
