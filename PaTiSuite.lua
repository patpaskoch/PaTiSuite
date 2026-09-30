-- PaTiSuite: an optional remote control for the PaTi windows — one row per installed addon to show or hide its
-- main window, plus "show all" / "hide all". No gameplay logic; every addon works the same without it.
-- It only uses the frames in _G.PaTiSuiteWindows (registered by each addon's embedded PaTiShared) and each addon's
-- own show/hide rules (window.suiteSetShown), so combat restrictions stay the addon's.
local addonName, ns = ...
local UI, L, Logic = ns.UI, ns.UI.L, ns.Logic

local DB
local SELF = addonName -- the panel registers itself too (for snapping) but is not listed

local function say(key, ...)
    print("|cff68caffPaTiSuite:|r " .. L[key]:format(...))
end

local function addonVersion()
    local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    return getMetadata and getMetadata(addonName, "Version") or "?"
end

-- Window ---------------------------------------------------------------------------------------

local WIDTH, LINE, PAD, BUTTON_WIDTH = 220, 22, UI.Spacing.MD, 98
local window = UI.CreateWindow("PaTiSuiteFrame", "PaTiSuite", WIDTH, 120)
local rows = {}
local entries = {}
local refresh -- defined below

-- Rows are buttons: a click does a safe UI action (show/hide a window), so they look clickable.
local function newRow(index)
    local row = CreateFrame("Button", nil, window)
    row:SetSize(WIDTH - 2 * PAD, LINE)
    row:SetPoint("TOPLEFT", PAD, -(UI.Sizes.HeaderHeight + UI.Spacing.SM + (index - 1) * LINE))
    row:RegisterForClicks("LeftButtonUp")
    local hover = row:CreateTexture(nil, "HIGHLIGHT")
    hover:SetAllPoints()
    hover:SetColorTexture(UI.Color("PanelHover"))
    row.dot = row:CreateTexture(nil, "ARTWORK")
    row.dot:SetSize(8, 8)
    row.dot:SetPoint("LEFT", UI.Spacing.SM, 0)
    row.name = row:CreateFontString(nil, "OVERLAY", UI.Fonts.Text)
    row.name:SetPoint("LEFT", row.dot, "RIGHT", UI.Spacing.MD, 0)
    row.state = row:CreateFontString(nil, "OVERLAY", UI.Fonts.Muted)
    row.state:SetPoint("RIGHT", -UI.Spacing.SM, 0)
    row:SetScript("OnClick", function(self)
        local entry = self.entry
        if not entry then return end
        if not Logic.Toggle(entry, InCombatLockdown()) then say("BLOCKED_COMBAT", Logic.Label(entry.name)) end
        refresh()
    end)
    UI.SetTooltip(row, function() return row.tooltipLines end)
    rows[index] = row
    return row
end

local function setAll(shown)
    local blocked = Logic.SetAll(entries, shown, InCombatLockdown())
    if #blocked > 0 then
        local names = {}
        for _, name in ipairs(blocked) do names[#names + 1] = Logic.Label(name) end
        say("BLOCKED_COMBAT", table.concat(names, ", "))
    end
    refresh()
end

local showAll = UI.CreateButton(window, "SHOW_ALL", BUTTON_WIDTH, function() setAll(true) end)
local hideAll = UI.CreateButton(window, "HIDE_ALL", BUTTON_WIDTH, function() setAll(false) end)
local empty = window:CreateFontString(nil, "OVERLAY", UI.Fonts.Muted)
empty:SetPoint("TOPLEFT", PAD, -(UI.Sizes.HeaderHeight + UI.Spacing.SM + 3))
empty:SetPoint("RIGHT", -PAD, 0)
empty:SetJustifyH("LEFT")
empty:SetWordWrap(true)

-- Watches the registered windows, so the list also follows /ph hide, the × of a window etc. (post-hooks only).
local hooked = {}
local function watch(frame)
    if hooked[frame] or type(frame.HookScript) ~= "function" then return end
    hooked[frame] = true
    frame:HookScript("OnShow", function() if refresh then refresh() end end)
    frame:HookScript("OnHide", function() if refresh then refresh() end end)
end

refresh = function()
    if not DB then return end
    entries = Logic.Entries(UI.WindowRegistry(), SELF)
    for index, entry in ipairs(entries) do
        watch(entry.frame)
        local row = rows[index] or newRow(index)
        local shown = Logic.IsShown(entry.frame)
        row.entry = entry
        row.dot:SetColorTexture(UI.Color(shown and "Accent" or "TextMuted"))
        row.name:SetText(Logic.Label(entry.name))
        row.name:SetTextColor(UI.Color(shown and "Text" or "TextMuted"))
        row.state:SetText(shown and L.SHOWN or L.HIDDEN)
        row.tooltipLines = { entry.name, shown and L.CLICK_TO_HIDE or L.CLICK_TO_SHOW }
        row:Show()
    end
    for index = #entries + 1, #rows do rows[index].entry = nil; rows[index]:Hide() end
    empty:SetText(#entries == 0 and L.NO_WINDOWS or "")
    empty:SetShown(#entries == 0)
    local listHeight = math.max(#entries, #entries == 0 and 2 or 0) * LINE
    local buttonsTop = UI.Sizes.HeaderHeight + UI.Spacing.SM + listHeight + UI.Spacing.SM
    showAll:ClearAllPoints()
    showAll:SetPoint("TOPLEFT", PAD, -buttonsTop)
    hideAll:ClearAllPoints()
    hideAll:SetPoint("TOPRIGHT", -PAD, -buttonsTop)
    showAll:SetEnabled(#entries > 0)
    hideAll:SetEnabled(#entries > 0)
    window:SetHeight(buttonsTop + UI.Sizes.ButtonHeight + PAD)
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
        { text = window:IsLocked() and "UNLOCK" or "LOCK", onClick = function() window:SetLocked(not window:IsLocked()) end },
        { text = "RESET_POSITION", onClick = resetPosition },
        { text = "HIDE", onClick = function() setShown(false) end },
    }
end)

-- Events ---------------------------------------------------------------------------------------
-- PLAYER_LOGIN: every addon has loaded (and registered its window), whatever the load order was.

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_REGEN_ENABLED") -- windows blocked in combat may have changed afterwards
events:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        PaTiSuiteDB = Logic.Migrate(PaTiSuiteDB)
        DB = PaTiSuiteDB
        UI.SetLanguage(DB.language)
        window:Attach(DB, 0, 320)
        window:SetScale(DB.scale)
    end
    refresh()
end)
UI.OnLanguageChanged(function() refresh() end)
