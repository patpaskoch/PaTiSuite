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
        assert.same({ true, 0.4, true, 1, "auto" }, { db.locked, db.opacity, db.snapWindows, db.scale, db.language })
        assert.equal(0.75, Logic.Migrate(nil).opacity)
        assert.equal("Heal", Logic.Label("PaTiHeal"))
    end)
end)
