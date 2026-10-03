-- PaTiSuite control panel logic with fake windows. Run via PaTiAdmin/tools/check.sh.
local wow = require("wow_api")

local function load()
    return wow.loadAddonFile("Logic.lua", {}).Logic
end

-- A plain window (like PaTiTank's) or one with its own suite rules (like PaTiHeal's, blocked in combat).
local function frame(shown, opts)
    opts = opts or {}
    local f = { shown = shown, calls = 0 }
    function f:IsShown() return self.shown end
    function f:SetShown(value) self.calls = self.calls + 1; self.shown = value end
    function f:IsProtected() return opts.protected == true end
    if opts.suite then
        function f:SetSuiteShown(value)
            if opts.blocked then return false end
            self:SetShown(value)
            return true
        end
    end
    return f
end

describe("Logic.Entries", function()
    it("lists only installed windows, in suite order, without the control panel itself", function()
        local Logic = load()
        local registry = { PaTiTank = frame(true), PaTiHeal = frame(true), PaTiSuite = frame(true), PaTiZeta = frame(false) }
        local names = {}
        for _, entry in ipairs(Logic.Entries(registry, "PaTiSuite")) do names[#names + 1] = entry.name end
        assert.same({ "PaTiHeal", "PaTiTank", "PaTiZeta" }, names)
    end)

    it("ignores a missing registry, broken entries and frames without Show/Hide", function()
        local Logic = load()
        assert.same({}, Logic.Entries(nil, "PaTiSuite"))
        assert.same({}, Logic.Entries({ PaTiHeal = "x", PaTiTank = {}, [5] = frame(true) }, "PaTiSuite"))
    end)
end)

describe("Logic.Toggle / SetAll", function()
    it("toggles one window: visible → hidden → visible", function()
        local Logic = load()
        local tank = frame(true)
        local entry = { name = "PaTiTank", frame = tank }
        assert.is_true(Logic.Toggle(entry, false))
        assert.is_false(tank.shown)
        assert.is_true(Logic.Toggle(entry, false))
        assert.is_true(tank.shown)
    end)

    it("shows all and hides all installed windows, touching only those that change", function()
        local Logic = load()
        local heal, tank = frame(false, { suite = true }), frame(true)
        local entries = { { name = "PaTiHeal", frame = heal }, { name = "PaTiTank", frame = tank } }
        assert.same({}, Logic.SetAll(entries, true, false))
        assert.is_true(heal.shown and tank.shown)
        assert.equal(0, tank.calls)
        assert.same({}, Logic.SetAll(entries, false, false))
        assert.is_false(heal.shown or tank.shown)
    end)

    it("respects the addon's combat rule and never touches a protected window in combat", function()
        local Logic = load()
        local heal = frame(true, { suite = true, blocked = true }) -- PaTiHeal in combat
        local raw = frame(true, { protected = true })            -- protected, no suite rules
        local tank = frame(true)
        local blocked = Logic.SetAll({ { name = "PaTiHeal", frame = heal }, { name = "PaTiRaw", frame = raw },
            { name = "PaTiTank", frame = tank } }, false, true)
        assert.same({ "PaTiHeal", "PaTiRaw" }, blocked)
        assert.is_true(heal.shown and raw.shown)
        assert.equal(0, raw.calls)
        assert.is_false(tank.shown)
    end)

    it("uses the addon's own shown-rule and survives a window that errors", function()
        local Logic = load()
        local alerts = frame(false)
        function alerts:IsSuiteShown() return true end -- auto-hidden, but not hidden by the player
        assert.is_true(Logic.IsShown(alerts))
        local broken = frame(true)
        function broken:SetShown() error("boom") end
        assert.is_false(Logic.SetShown(broken, false, false))
    end)
end)

describe("Settings", function()
    it("gets defaults for new and old saves and keeps saved values", function()
        local Logic = load()
        local db = Logic.Migrate({ locked = true, opacity = 0.4 })
        assert.same({ true, 0.4, 1, "auto" }, { db.locked, db.opacity, db.scale, db.language })
        assert.equal(0.75, Logic.Migrate(nil).opacity)
        assert.equal("Heal", Logic.Label("PaTiHeal"))
    end)
end)

describe("Logic.StateColor", function()
    it("is green (Success) for a shown window and grey (TextMuted) for a hidden one", function()
        local Logic = load()
        assert.equal("Success", Logic.StateColor(true))
        assert.equal("TextMuted", Logic.StateColor(false))
    end)
end)

describe("Logic.AllTarget (one button for show all / hide all)", function()
    it("hides all when every window is shown, otherwise shows all; one click flips the label", function()
        local Logic = load()
        local heal, tank = frame(true, { suite = true }), frame(false)
        local entries = { { name = "PaTiHeal", frame = heal }, { name = "PaTiTank", frame = tank } }
        assert.is_true(Logic.AllTarget(entries)) -- one hidden → "Show all"
        Logic.SetAll(entries, Logic.AllTarget(entries), false)
        assert.is_true(heal.shown and tank.shown)
        assert.is_false(Logic.AllTarget(entries)) -- all shown → "Hide all"
        Logic.SetAll(entries, Logic.AllTarget(entries), false)
        assert.is_false(heal.shown or tank.shown)
        assert.is_true(Logic.AllTarget(entries))
    end)

    it("keeps the combat rule: a blocked window stays, the button then offers show all", function()
        local Logic = load()
        local heal, tank = frame(true, { suite = true, blocked = true }), frame(true)
        local entries = { { name = "PaTiHeal", frame = heal }, { name = "PaTiTank", frame = tank } }
        assert.same({ "PaTiHeal" }, Logic.SetAll(entries, Logic.AllTarget(entries), true))
        assert.is_true(heal.shown)
        assert.is_false(tank.shown)
        assert.is_true(Logic.AllTarget(entries))
        assert.is_true(Logic.AllTarget({}))
    end)
end)

describe("Schema 2: layout and collapsed", function()
    it("new saves get vertical and expanded", function()
        local db = load().Migrate(nil)
        assert.same({ "vertical", false, 4 }, { db.layout, db.collapsed, db.schema })
    end)

    it("an old schema-1 save keeps every value and its position", function()
        local db = load().Migrate({ schema = 1, opacity = 0.4, locked = true, scale = 1.25, language = "deDE",
            point = "TOPLEFT", relativePoint = "BOTTOMLEFT", x = 377, y = 447 })
        assert.same({ 0.4, true, 1.25, "deDE", "TOPLEFT", "BOTTOMLEFT", 377, 447 },
            { db.opacity, db.locked, db.scale, db.language, db.point, db.relativePoint, db.x, db.y })
        assert.same({ "vertical", false, 4 }, { db.layout, db.collapsed, db.schema })
    end)

    it("keeps a saved horizontal / collapsed choice and turns an unknown layout into vertical", function()
        local Logic = load()
        local db = Logic.Migrate({ schema = 2, layout = "horizontal", collapsed = true })
        assert.same({ "horizontal", true }, { db.layout, db.collapsed })
        assert.equal("vertical", Logic.Migrate({ layout = "foo" }).layout)
        assert.equal("vertical", Logic.Migrate({ layout = 3 }).layout)
    end)

    it("Restore Defaults: vertical, expanded, position untouched", function()
        local db = load().RestoreDefaults({ layout = "horizontal", collapsed = true, point = "TOPLEFT", x = 5, y = 6 })
        assert.same({ "vertical", false, "TOPLEFT", 5, 6 }, { db.layout, db.collapsed, db.point, db.x, db.y })
    end)
end)

describe("Logic.Arrange (entry positions)", function()
    it("vertical: one entry per line, as wide as the widest", function()
        local points, width, height = load().Arrange({ 40, 60, 50 }, "vertical", 22, 4, 560)
        assert.same({ { x = 0, y = 0 }, { x = 0, y = 22 }, { x = 0, y = 44 } }, points)
        assert.same({ 60, 66 }, { width, height })
    end)

    it("horizontal: side by side with a gap, each only as wide as its own text", function()
        local points, width, height = load().Arrange({ 40, 60, 50 }, "horizontal", 22, 4, 560)
        assert.same({ { x = 0, y = 0 }, { x = 44, y = 0 }, { x = 108, y = 0 } }, points)
        assert.same({ 158, 22 }, { width, height })
    end)

    it("horizontal: wraps to a new line before maxWidth, never mid-entry", function()
        local points, width, height = load().Arrange({ 60, 60, 60 }, "horizontal", 22, 4, 130)
        assert.same({ { x = 0, y = 0 }, { x = 64, y = 0 }, { x = 0, y = 22 } }, points)
        assert.same({ 124, 44 }, { width, height })
    end)

    it("no entries: nothing to place", function()
        local points, width, height = load().Arrange({}, "horizontal", 22, 4, 560)
        assert.same({ {}, 0, 0 }, { points, width, height })
    end)
end)

describe("Schema 3: PaTiSuite remembers shown/hidden over /reload", function()
    local function entriesOf(heal, tank)
        return { { name = "PaTiHeal", frame = heal }, { name = "PaTiTank", frame = tank } }
    end

    it("schema 2 → 4 keeps every setting and the position, starts with no remembered windows", function()
        local db = load().Migrate({ schema = 2, opacity = 0.4, locked = true, scale = 1.25, language = "deDE",
            layout = "horizontal", collapsed = true, point = "TOPLEFT", x = 7, y = 8 })
        assert.same({ 0.4, true, 1.25, "deDE", "horizontal", true, "TOPLEFT", 7, 8, 4 }, { db.opacity, db.locked,
            db.scale, db.language, db.layout, db.collapsed, db.point, db.x, db.y, db.schema })
        assert.same({}, db.visibility)
    end)

    it("keeps valid entries and drops broken ones; Restore Defaults forgets them all", function()
        local Logic = load()
        local db = Logic.Migrate({ visibility = { PaTiHeal = false, PaTiTank = true, PaTiQuest = "no", [3] = true } })
        assert.same({ PaTiHeal = false, PaTiTank = true }, db.visibility)
        assert.same({}, Logic.Migrate({ visibility = "broken" }).visibility)
        assert.same({}, Logic.RestoreDefaults(db).visibility)
    end)

    it("login restore: no entry leaves the window alone; false hides it, true shows it", function()
        local Logic = load()
        local heal, tank = frame(true, { suite = true }), frame(false)
        assert.same({}, Logic.ApplySaved(entriesOf(heal, tank), {}, false))
        assert.same({ true, false, 0, 0 }, { heal.shown, tank.shown, heal.calls, tank.calls })
        assert.same({}, Logic.ApplySaved(entriesOf(heal, tank), { PaTiHeal = false, PaTiTank = true }, false))
        assert.same({ false, true }, { heal.shown, tank.shown })
    end)

    it("login restore in combat: a blocked window is named for after combat, nothing else changes", function()
        local Logic = load()
        local heal, tank = frame(true, { suite = true, blocked = true }), frame(true)
        assert.same({ "PaTiHeal" }, Logic.ApplySaved(entriesOf(heal, tank), { PaTiHeal = false, PaTiTank = false }, true))
        assert.same({ true, false }, { heal.shown, tank.shown })
    end)

    it("a successful click is remembered, a click blocked in combat is not", function()
        local Logic = load()
        local visibility = {}
        local heal = frame(true, { suite = true })
        assert.is_true(Logic.Toggle({ name = "PaTiHeal", frame = heal }, false, visibility))
        assert.same({ PaTiHeal = false }, visibility)
        local blocked = frame(true, { suite = true, blocked = true })
        assert.is_false(Logic.Toggle({ name = "PaTiAuras", frame = blocked }, true, visibility))
        assert.same({ PaTiHeal = false }, visibility)
    end)

    it("show all / hide all remembers only the windows that are now as wanted", function()
        local Logic = load()
        local visibility = { PaTiHeal = true }
        local heal, tank = frame(true, { suite = true, blocked = true }), frame(true)
        Logic.SetAll(entriesOf(heal, tank), false, true, visibility) -- hide all in combat: Heal is blocked
        assert.same({ PaTiHeal = true, PaTiTank = false }, visibility)
        heal = frame(false, { suite = true })
        Logic.SetAll(entriesOf(heal, tank), true, false, visibility)
        assert.same({ PaTiHeal = true, PaTiTank = true }, visibility)
    end)
end)

describe("Logic.Arrange: horizontal row with the 'all' button as its last element", function()
    it("button right after the last entry, no wrap while everything fits", function()
        local points, width, height = load().Arrange({ 40, 60, 50, 90 }, "horizontal", 22, 4, 1000)
        assert.same({ x = 162, y = 0 }, points[4])
        assert.same({ 252, 22 }, { width, height })
    end)

    it("wraps cleanly when the screen width is exceeded — the button moves to the next line on its own", function()
        local points, width, height = load().Arrange({ 40, 60, 50, 90 }, "horizontal", 22, 4, 200)
        assert.same({ x = 0, y = 22 }, points[4])
        assert.same({ 158, 44 }, { width, height })
    end)

    it("a wider button text (other language) changes the layout as expected", function()
        local Logic = load()
        local _, narrow = Logic.Arrange({ 40, 60, 50, 90 }, "horizontal", 22, 4, 1000)
        local _, wide = Logic.Arrange({ 40, 60, 50, 120 }, "horizontal", 22, 4, 1000)
        assert.equal(30, wide - narrow)
        local points = Logic.Arrange({ 40, 60, 50, 120 }, "horizontal", 22, 4, 270)
        assert.same({ x = 0, y = 22 }, points[4]) -- 162 + 120 > 270: wraps instead of being cut off
    end)
end)

describe("Suite order with PaTiRota, PaTiGroup and PaTiLead (2026-10-02)", function()
    it("lists every runtime addon in the suite order; Group and Lead are separate entries", function()
        local Logic = load()
        local registry = {}
        for _, name in ipairs({ "PaTiAlerts", "PaTiSocial", "PaTiDungeon", "PaTiQuest", "PaTiLead", "PaTiGroup",
            "PaTiRota", "PaTiTank", "PaTiAuras", "PaTiHeal", "PaTiSuite" }) do
            registry[name] = frame(true)
        end
        local names = {}
        for _, entry in ipairs(Logic.Entries(registry, "PaTiSuite")) do names[#names + 1] = Logic.Label(entry.name) end
        assert.same({ "Heal", "Auras", "Tank", "Rota", "Group", "Lead", "Quest", "Dungeon", "Social", "Alerts" }, names)
    end)
end)

describe("Schema 4: the old PaTiGroup visibility belongs to PaTiLead", function()
    it("a remembered PaTiGroup choice moves to PaTiLead; the new PaTiGroup starts without an override", function()
        local db = load().Migrate({ schema = 3, visibility = { PaTiGroup = false, PaTiHeal = true } })
        assert.same({ PaTiLead = false, PaTiHeal = true }, db.visibility)
        assert.equal(4, db.schema)
    end)

    it("an own PaTiLead entry wins; the old PaTiGroup entry is dropped anyway", function()
        local db = load().Migrate({ schema = 3, visibility = { PaTiGroup = false, PaTiLead = true } })
        assert.same({ PaTiLead = true }, db.visibility)
    end)

    it("runs once: after schema 4 a PaTiGroup entry is the new addon's own choice and stays", function()
        local Logic = load()
        local db = Logic.Migrate({ schema = 3, visibility = { PaTiGroup = true } })
        db.visibility.PaTiGroup = false -- the player hides the new PaTiGroup later
        db = Logic.Migrate(db)
        assert.same({ PaTiLead = true, PaTiGroup = false }, db.visibility)
    end)

    it("older saves (schema 1/2) and new characters migrate without errors", function()
        local Logic = load()
        assert.same({}, Logic.Migrate({ schema = 2 }).visibility)
        assert.same({}, Logic.Migrate(nil).visibility)
        assert.equal(4, Logic.Migrate(nil).schema)
    end)
end)

describe("Logic.SetAllThemes (PaTiSuite: one theme for all windows)", function()
    it("asks each window through its own SetSuiteTheme; skips windows without it and failing ones", function()
        local Logic = load()
        local calls = {}
        local function themed(name, result)
            local f = frame(true)
            f.SetSuiteTheme = function(_, id) calls[#calls + 1] = name .. "=" .. id; return result end
            return f
        end
        local failing = frame(true)
        failing.SetSuiteTheme = function() error("broken") end
        local entries = { { name = "PaTiHeal", frame = themed("PaTiHeal", true) },
            { name = "PaTiTank", frame = frame(true) }, -- older PaTiShared: no contract
            { name = "PaTiAuras", frame = failing },
            { name = "PaTiRota", frame = themed("PaTiRota", false) } } -- not loaded yet (no DB)
        assert.same({ "PaTiHeal" }, Logic.SetAllThemes(entries, "dracula"))
        assert.same({ "PaTiHeal=dracula", "PaTiRota=dracula" }, calls)
    end)
end)
