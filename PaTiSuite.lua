-- PaTiSuite: an optional remote control for the PaTi windows — one row per installed addon to show or hide its
-- main window, plus one "show all" / "hide all" button. No gameplay logic; every addon works the same without it.
-- It only uses the frames in _G.PaTiSuiteWindows (registered by each addon's embedded PaTiShared) and each addon's
-- own show/hide rules (window.suiteSetShown), so combat restrictions stay the addon's.
local addonName, ns = ...
local UI, L, Logic = ns.UI, ns.UI.L, ns.Logic

local DB
local SELF = addonName -- the panel registers itself too (every PaTi main window does) but is not listed

local function say(key, ...)
    print("|cff68caffPaTiSuite:|r " .. L[key]:format(...))
end

local function addonVersion()
    local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    return getMetadata and getMetadata(addonName, "Version") or "?"
end

-- Window ---------------------------------------------------------------------------------------
-- Compact: one entry per addon = status dot + short name, sized to its text (owner wish 2026-10-02). Vertical =
-- one entry per line, horizontal = side by side (Logic.Arrange). The window is as wide as its widest part: the
-- entries, the "all" button or the header (title + ••• menu button).

local LINE, PAD, DOT = 22, UI.Spacing.MD, 8
local window = UI.CreateWindow("PaTiSuiteFrame", "PaTiSuite", 120, 120)
window:SetCombatMovable(true) -- no secure children: may be dragged in combat too (PaTiShared)
local content = CreateFrame("Frame", nil, window) -- everything below the header; hidden while collapsed
content:SetPoint("TOPLEFT", 0, -UI.Sizes.HeaderHeight)
content:SetPoint("BOTTOMRIGHT")
local rows = {}
local entries = {}
local refresh -- defined below

-- Entries are buttons: a click does a safe UI action (show/hide a window), so they look clickable.
local function newRow(index)
    local row = CreateFrame("Button", nil, content)
    row:SetHeight(LINE)
    row:RegisterForClicks("LeftButtonUp")
    -- Hover like the PaTiShared popup: a background texture under the text (a HIGHLIGHT layer would cover it).
    local hover = row:CreateTexture(nil, "BACKGROUND")
    hover:SetAllPoints()
    hover:SetColorTexture(UI.Color("PanelHover"))
    hover:Hide()
    row:HookScript("OnEnter", function() hover:Show() end)
    row:HookScript("OnLeave", function() hover:Hide() end)
    row.dot = row:CreateTexture(nil, "ARTWORK")
    row.dot:SetSize(DOT, DOT)
    row.dot:SetPoint("LEFT", UI.Spacing.SM, 0)
    row.name = row:CreateFontString(nil, "OVERLAY", UI.Fonts.Text)
    row.name:SetPoint("LEFT", row.dot, "RIGHT", UI.Spacing.MD, 0)
    row.name:SetWordWrap(false)
    row:SetScript("OnClick", function(self)
        local entry = self.entry
        if not entry then return end
        -- Remembered over /reload when done (DB.visibility); a click blocked in combat remembers nothing.
        if not Logic.Toggle(entry, InCombatLockdown(), DB.visibility) then
            say("BLOCKED_COMBAT", Logic.Label(entry.name))
        end
        refresh()
    end)
    UI.SetTooltip(row, function() return row.tooltipLines end)
    rows[index] = row
    return row
end

-- Width an entry needs: dot + gap + name, with a small margin on both sides.
local function rowWidth(row)
    return UI.Spacing.SM + DOT + UI.Spacing.MD + math.ceil(UI.TextWidth(row.name)) + UI.Spacing.SM
end

local function setAll(shown)
    local blocked = Logic.SetAll(entries, shown, InCombatLockdown(), DB.visibility) -- remembered over /reload
    if #blocked > 0 then
        local names = {}
        for _, name in ipairs(blocked) do names[#names + 1] = Logic.Label(name) end
        say("BLOCKED_COMBAT", table.concat(names, ", "))
    end
    refresh()
end

-- One button for both: "Hide all" while every window is shown, otherwise "Show all" (owner wish 2026-09-30).
-- Width nil = fitted to its text (follows language changes).
local allButton = UI.CreateButton(content, "SHOW_ALL", nil, function() setAll(Logic.AllTarget(entries)) end)
local empty = content:CreateFontString(nil, "OVERLAY", UI.Fonts.Muted)
empty:SetPoint("TOPLEFT", PAD, -(UI.Spacing.SM + 3))
empty:SetJustifyH("LEFT")
empty:SetWordWrap(true)
local EMPTY_WIDTH = 160 -- the "no window found" hint wraps inside this width

-- Watches the registered windows, so the list also follows /ph hide, the × of a window etc. (post-hooks only).
local hooked = {}
local function watch(frame)
    if hooked[frame] or type(frame.HookScript) ~= "function" then return end
    hooked[frame] = true
    frame:HookScript("OnShow", function() if refresh then refresh() end end)
    frame:HookScript("OnHide", function() if refresh then refresh() end end)
end

-- Header needs: title, gap, ••• button (UI.CreateWindow places them at Spacing.MD / Spacing.XS from the edges).
local function headerWidth()
    return UI.Spacing.MD + math.ceil(UI.TextWidth(window.title)) + UI.Spacing.LG + UI.Sizes.HeaderHeight
        + UI.Spacing.XS
end

-- Horizontal: how wide the row may get before it wraps — a share of the screen, in the panel's own scale.
local function maxRowWidth()
    local screen = UIParent:GetWidth() * UIParent:GetEffectiveScale() / window:GetEffectiveScale()
    return screen * Logic.SCREEN_SHARE - 2 * PAD
end

-- Places the entries and the button, then sizes the window; collapsed = header only. Vertical: the button below
-- the list. Horizontal: the button is the last element of the same row (owner wish 2026-10-02) and wraps with it.
local function applyLayout()
    local inline = DB.layout == "horizontal" and #entries > 0
    local widths = {}
    for index = 1, #entries do widths[index] = rowWidth(rows[index]) end
    if inline then widths[#widths + 1] = allButton:GetWidth() end
    local points, usedWidth, usedHeight = Logic.Arrange(widths, DB.layout, LINE, UI.Spacing.SM, maxRowWidth())
    if #entries == 0 then usedWidth, usedHeight = EMPTY_WIDTH, 2 * LINE end
    local inner = math.max(usedWidth, allButton:GetWidth(), headerWidth() - 2 * PAD)
    for index = 1, #entries do
        local row, point = rows[index], points[index]
        row:SetWidth(DB.layout == "vertical" and inner or widths[index]) -- vertical: the whole line is clickable
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT", PAD + point.x, -(UI.Spacing.SM + point.y))
    end
    empty:SetWidth(inner)
    allButton:ClearAllPoints()
    local contentHeight
    if inline then
        local point = points[#widths]
        allButton:SetPoint("TOPLEFT", content, "TOPLEFT", PAD + point.x, -(UI.Spacing.SM + point.y))
        contentHeight = UI.Spacing.SM + usedHeight + PAD
    else
        local buttonTop = UI.Spacing.SM + usedHeight + UI.Spacing.SM
        allButton:SetPoint("TOP", content, "TOPLEFT", PAD + inner / 2, -buttonTop)
        contentHeight = buttonTop + UI.Sizes.ButtonHeight + PAD
    end
    window:SetWidth(inner + 2 * PAD)
    content:SetShown(not DB.collapsed)
    window:SetHeight(UI.Sizes.HeaderHeight + (DB.collapsed and 0 or contentHeight))
end

refresh = function()
    if not DB then return end
    entries = Logic.Entries(UI.WindowRegistry(), SELF)
    for index, entry in ipairs(entries) do
        watch(entry.frame)
        local row = rows[index] or newRow(index)
        local shown = Logic.IsShown(entry.frame)
        row.entry = entry
        row.dot:SetColorTexture(UI.Color(Logic.StateColor(shown)))
        row.name:SetText(Logic.Label(entry.name))
        row.name:SetTextColor(UI.Color(shown and "Text" or "TextMuted"))
        row.tooltipLines = { entry.name, shown and L.CLICK_TO_HIDE or L.CLICK_TO_SHOW }
        row:Show()
    end
    for index = #entries + 1, #rows do rows[index].entry = nil; rows[index]:Hide() end
    empty:SetText(#entries == 0 and L.NO_WINDOWS or "")
    empty:SetShown(#entries == 0)
    UI.BindText(allButton.label, Logic.AllTarget(entries) and "SHOW_ALL" or "HIDE_ALL")
    allButton:SetEnabled(#entries > 0)
    applyLayout()
end

local function toggleCollapsed() -- no secure frames: fine in combat
    DB.collapsed = not DB.collapsed
    refresh()
end

-- Settings -------------------------------------------------------------------------------------

local modal

local function buildSettings()
    modal = UI.CreateModal("PaTiSuiteSettings", function() return "PaTiSuite " .. L.SETTINGS end, 360)
    modal:AddSection("GENERAL")
    modal:AddRow("LANGUAGE", UI.CreateLanguageDropdown(modal, DB, 170))
    local scales = {}
    for _, scale in ipairs(Logic.SCALES) do
        scales[#scales + 1] = { value = scale, text = function() return ("%d %%"):format(scale * 100 + 0.5) end }
    end
    modal:AddRow("SCALE", UI.CreateDropdown(modal, 170, {
        items = function() return scales end,
        get = function() return DB.scale end,
        set = function(scale) DB.scale = scale; window:SetScale(scale) end, -- no secure frames: fine in combat
    }))
    modal:AddControls(UI.CreateCheckbox(modal, "LOCK_WINDOW", {
        get = function() return window:IsLocked() end,
        set = function(locked) window:SetLocked(locked) end,
    }))
    UI.AddWindowSettings(modal, window)
    modal:AddSection("DISPLAY")
    local layouts = {}
    for _, layout in ipairs(Logic.LAYOUTS) do
        layouts[#layouts + 1] = { value = layout, text = function() return L[layout:upper()] end }
    end
    modal:AddRow("LAYOUT", UI.CreateDropdown(modal, 170, {
        items = function() return layouts end,
        get = function() return DB.layout end,
        set = function(layout) DB.layout = layout; refresh() end, -- applied at once, no /reload
    }))
    modal:Finish(function()
        Logic.RestoreDefaults(DB)
        window:ApplyOpacity()
        UI.SetLanguage(DB.language)
        window:SetLocked(DB.locked)
        window:SetScale(DB.scale)
        refresh()
    end)
end

local function openSettings()
    if not modal then buildSettings() end
    modal:Show()
end

-- Commands -------------------------------------------------------------------------------------

local function setShown(shown)
    window:SetShown(shown)
    if shown then refresh() else say("HIDDEN_HINT") end
end

local function resetPosition()
    DB.point, DB.relativePoint, DB.x, DB.y = nil, nil, nil, nil
    window:Attach(DB, 0, 320)
end

local function printDebug()
    local names = {}
    for name in pairs(UI.WindowRegistry()) do names[#names + 1] = tostring(name) end
    table.sort(names)
    print("|cff68caffPaTiSuite Debug:|r")
    print(("  PaTiSuite %s · PaTiShared UI %s · registered windows: %s · combat %s"):format(addonVersion(),
        tostring(UI.VERSION), #names > 0 and table.concat(names, ", ") or "none", InCombatLockdown() and "yes" or "no"))
end

local COMMANDS = {
    [""] = function() setShown(not window:IsShown()) end,
    show = function() setShown(true) end,
    hide = function() setShown(false) end,
    showall = function() setAll(true) end,
    hideall = function() setAll(false) end,
    lock = function() window:SetLocked(true) end,
    unlock = function() window:SetLocked(false) end,
    reset = resetPosition,
    settings = openSettings,
    debug = printDebug,
    version = function() say("VERSION", addonVersion()) end,
}

SLASH_PATISUITE1 = "/patisuite"
SLASH_PATISUITE2 = "/psuite"
SlashCmdList.PATISUITE = function(message)
    local command = COMMANDS[(message or ""):match("^%s*(.-)%s*$"):lower()]
    if command and DB then command() else say("HELP") end
end

window:SetMenu(function()
    if not DB then return {} end
    return {
        { text = "SETTINGS", onClick = openSettings },
        { text = window:IsLocked() and "UNLOCK" or "LOCK",
            onClick = function() window:SetLocked(not window:IsLocked()) end },
        { text = DB.collapsed and "EXPAND" or "COLLAPSE", onClick = toggleCollapsed },
        { text = "RESET_POSITION", onClick = resetPosition },
        { text = "HIDE", onClick = function() setShown(false) end },
    }
end)

-- Events ---------------------------------------------------------------------------------------

-- First PLAYER_ENTERING_WORLD (after every addon's PLAYER_LOGIN, whatever the load order): windows go back to what
-- the player last chose in PaTiSuite (DB.visibility), once per login/reload. Windows blocked in combat (/reload in
-- combat) get it after combat. Shows/hides by other means only refresh the list; they are not remembered.
local restored, restorePending = false, nil

local function restoreVisibility(only)
    local list = {}
    for _, entry in ipairs(Logic.Entries(UI.WindowRegistry(), SELF)) do
        if not only or only[entry.name] then list[#list + 1] = entry end
    end
    local blocked = Logic.ApplySaved(list, DB.visibility, InCombatLockdown())
    restorePending = nil
    if #blocked > 0 then
        restorePending = {}
        for _, name in ipairs(blocked) do restorePending[name] = true end
    end
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED") -- windows blocked in combat may have changed afterwards
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        PaTiSuiteDB = Logic.Migrate(PaTiSuiteDB)
        DB = PaTiSuiteDB
        UI.SetLanguage(DB.language)
        window:Attach(DB, 0, 320)
        window:SetScale(DB.scale)
    elseif not DB then
        return
    elseif event == "PLAYER_ENTERING_WORLD" and not restored then
        restored = true
        restoreVisibility()
    elseif event == "PLAYER_REGEN_ENABLED" and restorePending then
        restoreVisibility(restorePending)
    end
    refresh()
end)
UI.OnLanguageChanged(function() refresh() end)
