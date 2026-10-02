-- PaTiSuite: settings and the window list, without WoW API calls (tested in tests/logic_spec.lua).
-- A remote control only: it shows/hides the main windows other PaTi addons registered in _G.PaTiSuiteWindows
-- (PaTiShared). It holds no gameplay logic; no addon needs PaTiSuite.
local _, ns = ...
local Logic = {}
ns.Logic = Logic

Logic.SCHEMA = 4
Logic.SCALES = { 0.8, 0.9, 1, 1.1, 1.25, 1.5 }
Logic.ORDER = { "PaTiHeal", "PaTiAuras", "PaTiTank", "PaTiRota", "PaTiGroup", "PaTiLead", "PaTiQuest", "PaTiDungeon",
    "PaTiSocial", "PaTiAlerts" }
Logic.LAYOUTS = { "vertical", "horizontal" }
-- Horizontal: the row may use this share of the screen width before it wraps (PaTiSuite.lua computes the px).
Logic.SCREEN_SHARE = 0.9

-- Position (point, relativePoint, x, y) is written by the PaTiShared window, not listed here.
Logic.DEFAULTS = {
    opacity = 0.75,
    locked = false,
    scale = 1,
    language = "auto",
    layout = "vertical",
    collapsed = false,
}

local function validLayout(layout)
    for _, known in ipairs(Logic.LAYOUTS) do
        if layout == known then return true end
    end
    return false
end

-- Schema 2 (2026-10-02) adds layout and collapsed; schema 3 (2026-10-02) adds visibility = { [addonName] = true |
-- false }: what the player chose in PaTiSuite. A missing entry = PaTiSuite leaves that window as the addon starts it.
-- Every older value and the position stay as they are; anything else in visibility is dropped.
-- Schema 4 (2026-10-02): the former PaTiGroup (markers, ready check) is now PaTiLead and "PaTiGroup" a new addon
-- (party awareness). A remembered visibility.PaTiGroup belonged to the old one: it moves to PaTiLead (unless PaTiLead
-- already has its own entry), so the new PaTiGroup starts without an old override.
function Logic.Migrate(db)
    db = db or {}
    for key, value in pairs(Logic.DEFAULTS) do
        if db[key] == nil then db[key] = value end
    end
    if not validLayout(db.layout) then db.layout = Logic.DEFAULTS.layout end
    local visibility = {}
    for name, shown in pairs(type(db.visibility) == "table" and db.visibility or {}) do
        if type(name) == "string" and type(shown) == "boolean" then visibility[name] = shown end
    end
    db.visibility = visibility
    if (db.schema or 0) < 4 and visibility.PaTiGroup ~= nil then
        if visibility.PaTiLead == nil then visibility.PaTiLead = visibility.PaTiGroup end
        visibility.PaTiGroup = nil
    end
    db.schema = Logic.SCHEMA
    return db
end

-- Restore Defaults also forgets the remembered visibility: every window starts as its addon starts it again.
function Logic.RestoreDefaults(db)
    for key, value in pairs(Logic.DEFAULTS) do db[key] = value end
    db.visibility = {}
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

-- Show/hide all. Returns the names that could not be changed now (e.g. in combat). visibility (optional,
-- PaTiSuiteDB.visibility): every window that is now as wanted is remembered; a blocked one keeps its old entry.
function Logic.SetAll(entries, shown, inCombat, visibility)
    local blocked = {}
    for _, entry in ipairs(entries) do
        if Logic.IsShown(entry.frame) ~= shown and not Logic.SetShown(entry.frame, shown, inCombat) then
            blocked[#blocked + 1] = entry.name
        elseif visibility then
            visibility[entry.name] = shown
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

-- One click on a row: visible → hide, hidden → show. Returns true if done; then the new state is remembered in
-- visibility (optional). A blocked click (combat) remembers nothing.
function Logic.Toggle(entry, inCombat, visibility)
    local shown = not Logic.IsShown(entry.frame)
    local done = Logic.SetShown(entry.frame, shown, inCombat)
    if done and visibility then visibility[entry.name] = shown end
    return done
end

-- Pure: where each entry goes. widths = entry widths (px). "vertical": one per line; "horizontal": side by side
-- with `gap` between them, a new line only when the next entry would pass maxWidth. Returns the positions
-- { { x, y }, … } (y downwards from the top), the width and the height used.
function Logic.Arrange(widths, layout, lineHeight, gap, maxWidth)
    local points, x, y, width = {}, 0, 0, 0
    for index, entryWidth in ipairs(widths) do
        if layout == "horizontal" then
            if x > 0 and x + entryWidth > maxWidth then x, y = 0, y + lineHeight end
            points[index] = { x = x, y = y }
            width = math.max(width, x + entryWidth)
            x = x + entryWidth + gap
        else
            points[index] = { x = 0, y = (index - 1) * lineHeight }
            width = math.max(width, entryWidth)
        end
    end
    if #widths == 0 then return points, 0, 0 end
    local height = layout == "horizontal" and y + lineHeight or #widths * lineHeight
    return points, width, height
end

-- After login: brings each window to the state the player last chose in PaTiSuite (visibility). Windows without an
-- entry are left alone. Returns the names that could not be changed now (in combat) — try again after combat.
function Logic.ApplySaved(entries, visibility, inCombat)
    local blocked = {}
    for _, entry in ipairs(entries) do
        local wanted = visibility and visibility[entry.name]
        if type(wanted) == "boolean" and Logic.IsShown(entry.frame) ~= wanted
            and not Logic.SetShown(entry.frame, wanted, inCombat) then
            blocked[#blocked + 1] = entry.name
        end
    end
    return blocked
end
