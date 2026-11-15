-- Run with: lua tests/test-localization.lua [addon directory]
local root = arg[1] or "."
local addonName = "EinTickZuSpaetForeverViewport"

local function Client(locale, database)
    local env = setmetatable({}, { __index = _G })
    local namespace, frames, messages = {}, {}, {}
    local methods = {}
    local function Object()
        return setmetatable({ scripts = {}, shown = false, points = {} }, { __index = methods })
    end
    function methods:SetText(text) self.text = text end
    function methods:GetText() return self.text end
    function methods:SetChecked(checked) self.checked = checked end
    function methods:GetChecked() return self.checked end
    function methods:SetEnabled(enabled) self.enabled = enabled end
    function methods:SetSize(width, height) self.width, self.height = width, height end
    function methods:GetWidth() return self.width end
    function methods:GetHeight() return self.height end
    function methods:SetPoint(...) self.points[#self.points + 1] = { ... } end
    function methods:ClearAllPoints() self.points = {} end
    function methods:SetScript(event, callback) self.scripts[event] = callback end
    function methods:SetShown(shown) self.shown = shown end
    function methods:IsShown() return self.shown end
    function methods:Hide() self.shown = false end
    function methods:Show()
        self.shown = true
        if self.scripts.OnShow then self.scripts.OnShow(self) end
    end
    function methods:CreateTexture() return Object() end
    function methods:CreateFontString() return Object() end
    setmetatable(methods, { __index = function() return function() end end })
    env.UIParent = Object()
    env.UIParent:SetSize(1920, 1080)
    env.WorldFrame = Object()
    env.SlashCmdList = {}
    env.GetLocale = function() return locale end
    env.InCombatLockdown = function() return env.combat or false end
    env.ReloadUI = function() env.reloaded = true end
    env.DEFAULT_CHAT_FRAME = { AddMessage = function(_, message) messages[#messages + 1] = message end }
    env.CreateFrame = function(_, name, _, template)
        local frame = Object()
        if template == "BasicFrameTemplateWithInset" then frame.TitleBg = Object() end
        if template == "UICheckButtonTemplate" then frame.Text = Object() end
        frames[#frames + 1] = frame
        if name then env[name] = frame end
        return frame
    end
    env.EinTickZuSpaetForeverViewportDB = database
    for _, name in ipairs({ "Locales.lua", "EinTickZuSpaetForeverViewport.lua" }) do
        assert(loadfile(root .. "/" .. name, "t", env))(addonName, namespace)
    end
    local events = frames[#frames]
    events.scripts.OnEvent(events, "ADDON_LOADED", addonName)
    return env, namespace.L, messages, events
end

local legacy = Client("enUS", { bottom = 222, enabled = true })
assert(legacy.EinTickZuSpaetForeverViewportDB.profiles.Neu.bottom == 222, "legacy flat settings must still migrate")
local customDB = {
    version = 2,
    activeProfile = "MeinProfil",
    profiles = {
        Aktuell = { enabled = false, bottom = 0 },
        Neu = { enabled = true, bottom = 180 },
        MeinProfil = { enabled = true, bottom = 278, top = 9 },
        Current = { enabled = true, bottom = 123 },
    },
}
for _, locale in ipairs({ "deDE", "enUS", "frFR" }) do
    customDB.activeProfile = "MeinProfil"
    local env = Client(locale, customDB)
    assert(customDB.activeProfile == "MeinProfil" and customDB.profiles.MeinProfil.bottom == 278 and customDB.profiles.MeinProfil.top == 9)
    local slash = env.SlashCmdList.EINTICKZUSPAETFOREVERVIEWPORT
    slash("profile use Current") assert(customDB.activeProfile == "Current", "existing custom names must win over profile aliases")
    slash("current") assert(customDB.activeProfile == "Aktuell", "direct switch must always select built-in")
end
print("PASS: legacy migration and existing custom profiles preserved across locales")

for _, locale in ipairs({ "deDE", "enUS", "enGB", "frFR", "esES", "ruRU", "koKR", "zhCN" }) do
    local env, L, messages, events = Client(locale)
    local slash = env.SlashCmdList.EINTICKZUSPAETFOREVERVIEWPORT
    local db = env.EinTickZuSpaetForeverViewportDB
    local german = locale == "deDE"
    assert(L.current == (german and "Aktuell" or "Current"), locale)
    assert(L.quickSwitch == (german and "Schnellwechsel" or "Quick switch"), locale)
    slash("")
    local options = env[addonName .. "Options"]
    assert(options.currentButton.text == L.current and options.newButton.text == L.new)
    assert(options.enabledCheck.Text.text == L.enabled and options.backgroundCheck.Text.text == L.background)
    assert(options.applyButton.text == L.apply and options.closeButton.text == L.close and options.resetButton.text == L.reset)
    assert(options.hint.text == L.hint)
    assert(options.activeLabel.text == string.format(L.activeProfile, L.new))

    for _, pair in ipairs({ { "current", "Aktuell" }, { "neu", "Neu" }, { "aktuell", "Aktuell" }, { "NEW", "Neu" } }) do
        slash(pair[1])
        assert(db.activeProfile == pair[2], pair[1])
        assert(messages[#messages] == "|cffd9a441Ein Tick zu spät – Forever Viewport:|r " .. string.format(L.profileActivated, pair[2] == "Neu" and L.new or L.current))
    end
    slash("bottom 200")
    assert(db.profiles.Neu.bottom == 200)
    slash("unten 210")
    slash("oben 10")
    slash("links 20")
    slash("rechts 30")
    assert(db.profiles.Neu.bottom == 210 and db.profiles.Neu.top == 10 and db.profiles.Neu.left == 20 and db.profiles.Neu.right == 30)
    slash("off") assert(db.profiles.Neu.enabled == false)
    slash("an") assert(db.profiles.Neu.enabled == true)
    slash("hintergrund aus") assert(db.profiles.Neu.background == false)
    slash("background ON") assert(db.profiles.Neu.background == true)
    slash("top nope") assert(messages[#messages]:find(L.invalidNumber, 1, true))
    slash("profile use current") assert(db.activeProfile == "Aktuell")
    slash("profil verwenden new") assert(db.activeProfile == "Neu")
    for _, name in ipairs({ "current", "new", "Aktuell", "Neu" }) do slash("profile delete " .. name) end
    assert(db.profiles.Aktuell and db.profiles.Neu, "built-in profiles must remain protected via aliases")
    slash("profil speichern Raid")
    assert(db.activeProfile == "Raid" and db.profiles.Raid.bottom == 210)
    slash("profile list")
    assert(messages[#messages]:find(L.current, 1, true) and messages[#messages]:find(L.new, 1, true))
    slash("profile use nonexistent") assert(messages[#messages]:find(string.format(L.profileNotFound, "nonexistent"), 1, true))
    slash("profile delete Raid") assert(not db.profiles.Raid and db.activeProfile == "Neu")
    slash("profil speichern Test")
    slash("profil loeschen Test") assert(not db.profiles.Test)
    slash("profil speichern Test")
    slash("profil löschen Test") assert(not db.profiles.Test)
    slash("hilfe") assert(messages[#messages] == "|cffd9a441Ein Tick zu spät – Forever Viewport:|r " .. L.helpOther)
    slash("help") assert(messages[#messages]:find(L.helpOther, 1, true))
    env.combat = true
    slash("current") assert(messages[#messages - 1]:find(L.combatDeferred, 1, true))
    env.combat = false
    events.scripts.OnEvent(events, "PLAYER_REGEN_ENABLED")
    slash("new")
    slash("zuruecksetzen") assert(db.profiles.Neu.bottom == 145)
    slash("bottom 205")
    assert(not db.profiles.Current and not db.profiles.New, "localization must not rename stored built-ins")
    -- Reload the same SavedVariables under a different language.
    local changed = Client(german and "frFR" or "deDE", db)
    assert(changed.EinTickZuSpaetForeverViewportDB == db and db.profiles.Neu.bottom == 205)
    assert(db.activeProfile == "Neu", "switching locale must preserve active profile")
    print("PASS: " .. locale .. " UI/messages, bilingual commands, combat deferral and locale-switch persistence")
end
